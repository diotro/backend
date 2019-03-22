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


INSERT INTO weights VALUES (0, 0, 12);
INSERT INTO weights VALUES (1, 13, 25);
INSERT INTO weights VALUES (2, 26, 50);
INSERT INTO weights VALUES (3, 51, 100);
INSERT INTO weights VALUES (4, 100, 500);