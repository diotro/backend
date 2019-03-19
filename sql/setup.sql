CREATE TABLE dogs
(
  id SERIAL PRIMARY KEY,
  submission_time TIMESTAMP NOT NULL DEFAULT NOW(),
  image BYTEA NOT NULL,
  age_months INTEGER NOT NULL,
  weight INTEGER NOT NULL,
  breed VARCHAR(100) NOT NULL,
  submitter_email VARCHAR(300) NOT NULL UNIQUE
);
