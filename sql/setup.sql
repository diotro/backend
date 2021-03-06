-- this file represents the current status of the database:
-- however, this whole script has never been run in GCP SQL, because
-- incremental changes have been made.
-- TODO move to a migration based system.

-- TODO add logical deletion to dogs/voters. Lack of logical deletion required real deletion
--      for running the first iteration of the dog project, which lead to problems as the
--      emails of submitters were lost. Either have a table of "allowed dogs" which is cross-
--      referenced in the vote selection (maybe with a view of only eligible dogs), or similar

CREATE TABLE weights
(
  id    INTEGER PRIMARY KEY,
  lower INTEGER NOT NULL,
  upper INTEGER NOT NULL
);


INSERT INTO weights
VALUES (0, 0, 12);
INSERT INTO weights
VALUES (1, 13, 25);
INSERT INTO weights
VALUES (2, 26, 50);
INSERT INTO weights
VALUES (3, 51, 100);
INSERT INTO weights
VALUES (4, 100, 500);

CREATE TABLE dogs
(
  id              SERIAL PRIMARY KEY,
  submission_time TIMESTAMP                       NOT NULL DEFAULT NOW(),
  image           BYTEA                           NOT NULL,
  age_months      INTEGER                         NOT NULL,
  weight_id       INTEGER REFERENCES weights (id) NOT NULL,
  breed           VARCHAR(100)                    NOT NULL,
  submitter_email VARCHAR(300)                    NOT NULL
);


CREATE TYPE education_level AS ENUM (
  'No high school',
  'Some high school',
  'High school diploma or equivalent',
  'Vocational training',
  'Some college',
  'Associate''s degree',
  'Bachelor''s degree',
  'Post-undergraduate education'
  );

CREATE TABLE voters
(
  id                       SERIAL PRIMARY KEY,
  uuid                     UUID      NOT NULL,
  creation_time            TIMESTAMP NOT NULL DEFAULT now(),
  gender_identity          VARCHAR(300),
  age                      INTEGER,
  education                education_level,
  location                 VARCHAR(300),
  dog_ownership            BOOLEAN,
  northeastern_affiliation VARCHAR(300)
);

CREATE TYPE vote_result AS ENUM ('win', 'loss', 'tie');

-- result is the result of dog1 against dog2, as in, a win means dog1 beat dog2.
-- TODO change this table: should be something like "winner_id, loser_id, is_tie, left_id"
CREATE TABLE votes
(
  id              SERIAL PRIMARY KEY,
  submission_time TIMESTAMP NOT NULL DEFAULT NOW(),
  voter_id        INTEGER REFERENCES voters (id),
  dog1_id         INTEGER REFERENCES dogs (id),
  dog2_id         INTEGER REFERENCES dogs (id),
  result          vote_result
);
