import functools
import json
import traceback

from jsonschema import validate

from util.get_pool import get_pool

pg_pool = None


def cloudfunction(input_json=True, in_schema = None, out_schema=None):
    """

    :param input_json: if True, the child function is passed the json from the request, otherwise not
    :return: the cloudfunction wrapped function
    """

    def cloudfunction_decorator(f):
        """ Wraps a function with two arguments, the first of which is a json object that it expects to be sent with the
        request, and the second is a postgresql pool. It modifies it by:
         - setting CORS headers and responding to OPTIONS requests with `Allow-Origin *`
         - passing a connection from a global postgres connection pool
         - adding logging, of all inputs as well as error tracebacks.

        :param f: A function that takes a `request` and a `pgpool` and returns a json-serializable object
        :return: a function that accepts one argument, a Flask request, and calls f with the modifications listed
        """
        @functools.wraps(f)
        def wrapped(request):
            global pg_pool

            # If given an OPTIONS request, tell the requester that we allow all CORS requests (pre-flight stage)
            if request.method == 'OPTIONS':
                # Allows GET and POST requests from any origin with the Content-Type
                # header and caches preflight response for an 3600s
                headers = {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Max-Age': '3600'
                }

                return ('', 204, headers)

            # If it's not a CORS OPTIONS request, still include the base header.
            headers = {
                'Access-Control-Allow-Origin': '*'
            }

            # Lazily initialize a global pg_pool, so that multiple cloudfunctions can share the pool and not create one
            # each time.
            if not pg_pool:
                pg_pool = get_pool()

            try:
                conn = pg_pool.getconn()

                if input_json:
                    request_json = request.get_json()
                    if in_schema:
                        print(repr({"request_json": request_json}))
                        validate(request_json, in_schema)

                    function_output = f(request_json, conn)
                else:
                    function_output = f(conn)

                if out_schema:
                    validate(function_output, out_schema)

                conn.commit()
                pg_pool.putconn(conn)

                print(repr({"response_json": function_output}))

                response_json = json.dumps(function_output)
                return (response_json, 200, headers)
            except:
                # Make sure to put the connection back in the pool, even if there has been an exception
                try:
                    # But conn may not be defined, so wrap this call in a try/except block
                    pg_pool.putconn(conn)
                except:
                    pass
                print("Error: Exception traceback: " + repr(traceback.format_exc()))
                return (traceback.format_exc(), 500, headers)

        return wrapped

    return cloudfunction_decorator


