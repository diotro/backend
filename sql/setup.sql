CREATE TABLE weights
(
  id INTEGER PRIMARY KEY,
  lower INTEGER NOT NULL,
  upper INTEGER NOT NULL
);

CREATE TABLE dogs
(
  id SERIAL PRIMARY KEY,
  submission_time TIMESTAMP NOT NULL DEFAULT NOW(),
  image BYTEA NOT NULL,
  age_months INTEGER NOT NULL,
  weight_id INTEGER REFERENCES weights(id) NOT NULL,
  breed VARCHAR(100) NOT NULL,
  submitter_email VARCHAR(300) NOT NULL UNIQUE
);


INSERT INTO weights VALUES (0, 0, 10);
-- ...
