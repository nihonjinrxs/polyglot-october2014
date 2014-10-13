/***************************************
  Polyglot Programming DC : October 2014
  Manipulating Data in Style with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-08-02
  **************************************
  This script uses common table
  expressions to explore employee 
  reporting relationships in the Chinook 
  database.
****************************************/

/* Setup -- set search path and drop functions if exist */
SET search_path TO chinook;
DROP FUNCTION chinook."OrgChartSubTree"(integer);

/* Let's create some queries to look at the employee hierarchy.
   First, we'll find the boss.
 */
SELECT * FROM chinook."Employee" WHERE "ReportsTo" IS NULL;

/* We can get reporting relationships via a self-join. */
SELECT 
	emp."EmployeeId", emp."LastName", emp."FirstName", emp."Title",
	boss."EmployeeId", boss."LastName", boss."FirstName", boss."Title"
FROM chinook."Employee" emp LEFT OUTER JOIN chinook."Employee" boss
	ON emp."ReportsTo" = boss."EmployeeId"
;

/* Now, to use those reporting relationships, we can create a 
   common table expression (CTE).  Let's find employees who
   report to bosses 10 years or more older than them.
 */
WITH "cteEmployeeHierarchy" (
	"empId", "empLast", "empFirst", "empTitle", 
	"bossId", "bossLast", "bossFirst", "bossTitle"
) AS (
	SELECT 
		emp."EmployeeId", emp."LastName", emp."FirstName", emp."Title",
		boss."EmployeeId", boss."LastName", boss."FirstName", boss."Title"
	FROM chinook."Employee" emp LEFT OUTER JOIN chinook."Employee" boss
		ON emp."ReportsTo" = boss."EmployeeId"
)
SELECT *
FROM "cteEmployeeHierarchy" cte LEFT OUTER JOIN chinook."Employee" b
	ON cte."bossId" = b."EmployeeId"
	LEFT OUTER JOIN chinook."Employee" e
	ON cte."empId" = e."EmployeeId"
WHERE e."BirthDate" - b."BirthDate" > INTERVAL '10 years'
;

/* The prior example is somewhat contrived, but the real power of CTEs is 
   recursion (actually, iteration, but the keyword is RECURSIVE.  Let's 
   rework that CTE to give us just the sub-hierarchy of employees under a 
   specific person including direct and indirect reports.
 */
WITH RECURSIVE "cteEmployeeHierarchy" (report, boss) AS (
    SELECT "EmployeeId" AS report, "ReportsTo" AS boss 
	FROM chinook."Employee" WHERE "EmployeeId" = 6
  UNION ALL
    SELECT e."EmployeeId" AS report, e."ReportsTo" AS boss
    FROM "cteEmployeeHierarchy" r 
		LEFT JOIN chinook."Employee" e ON r.report = e."ReportsTo"
	WHERE e."EmployeeId" IS NOT NULL
  )
SELECT boss, report
FROM "cteEmployeeHierarchy"
;

/* But now we have that pesky WHERE clause.  Let's make this reusable with a function. */
CREATE OR REPLACE FUNCTION chinook."OrgChartSubTree"(
	IN paramBossId INTEGER
) RETURNS TABLE (
	report INTEGER,
	boss INTEGER
) AS $$
	WITH RECURSIVE "cteEmployeeHierarchy" (report, boss) AS (
		SELECT "EmployeeId" AS report, "ReportsTo" AS boss 
		FROM chinook."Employee" WHERE "EmployeeId" = paramBossId
	  UNION ALL
		SELECT e."EmployeeId" AS report, e."ReportsTo" AS boss
		FROM "cteEmployeeHierarchy" r 
			LEFT JOIN chinook."Employee" e ON r.report = e."ReportsTo"
		WHERE e."EmployeeId" IS NOT NULL
	  )
	SELECT report, boss
	FROM "cteEmployeeHierarchy"
$$ LANGUAGE 'sql' STABLE;

SELECT boss, report FROM chinook."OrgChartSubTree" ( 2 );
SELECT boss, report FROM chinook."OrgChartSubTree" ( 3 );
SELECT boss, report FROM chinook."OrgChartSubTree" ( 6 );
SELECT boss, report FROM chinook."OrgChartSubTree" ( 1 );

/* Now, based on this, it might be nice to have an alias for the big boss' ID. */
CREATE OR REPLACE FUNCTION chinook."BigBossId"( ) RETURNS INTEGER AS $$
        SELECT 1 as "BigBossId"
$$ LANGUAGE 'sql' IMMUTABLE;

SELECT boss, report FROM chinook."OrgChartSubTree" ( chinook."BigBossId"( ) );

/* Using this function, let's explore the title reporting structure. */
SELECT 
        b."Title" AS "BossTitle", 
        r."Title" AS "ReportTitle", 
        COUNT(r."Title") AS "NumberOfReports"
FROM chinook."OrgChartSubTree" ( chinook."BigBossId"( ) ) t
        LEFT OUTER JOIN chinook."Employee" b ON t.boss = b."EmployeeId"
        LEFT OUTER JOIN chinook."Employee" r ON t.report = r."EmployeeId"
GROUP BY b."Title", r."Title"
;

