/***************************************
  Polyglot Programming DC : October 2014
  Manipulating Data in Style with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-08-04
  Revised: 2014-10-13
  **************************************
  This script demonstrates performance
  tuning using the EXPLAIN keyword and 
  indexes on columns for the data 
  imported via code in the GitHub repo:
    https://www.github.com/nihonjinrxs/dc311
****************************************/

/* To really see a difference, we'll need plenty of data.  Let's use DC311 data. */

SELECT count(*) FROM dc311.requests;

/* Index on a date field */

DROP INDEX IF EXISTS dc311.requests_resolutiondate_idx;

EXPLAIN
SELECT * FROM dc311.requests
WHERE resolutiondate > DATE '2013-04-01';

CREATE INDEX requests_resolutiondate_idx ON dc311.requests (resolutiondate);

EXPLAIN
SELECT * FROM dc311.requests
WHERE resolutiondate > DATE '2013-04-01';

/* Index on a text field */

DROP INDEX IF EXISTS dc311.requests_servicetypecode_idx;

EXPLAIN
SELECT * FROM dc311.requests
WHERE servicetypecode IN ('PRSVAVOP','DRIVEHSE');

CREATE INDEX requests_servicetypecode_idx ON dc311.requests (servicetypecode);
VACUUM ANALYZE;

EXPLAIN
SELECT * FROM dc311.requests
WHERE servicetypecode IN ('PRSVAVOP','DRIVEHSE');

/* Index on an expression */

DROP INDEX IF EXISTS requests_servicetypecode_lower_idx;

EXPLAIN
SELECT * FROM dc311.requests
WHERE lower(servicetypecode) IN ('prsvavop','drivehse');

CREATE INDEX requests_servicetypecode_lower_idx 
ON dc311.requests (lower(servicetypecode));
VACUUM ANALYZE;

EXPLAIN
SELECT * FROM dc311.requests
WHERE lower(servicetypecode) IN ('prsvavop','drivehse');

