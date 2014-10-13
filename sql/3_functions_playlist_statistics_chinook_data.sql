/***************************************
  Polyglot Programming DC : October 2014
  Manipulating Data in Style with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-08-02
  **************************************
  This script creates resuable functions
  to compute statistics on Playlist 
  records and associated Track records 
  in the Chinook database.
****************************************/

/* Setup -- set search path and drop functions if exist */
SET search_path TO chinook;
DROP FUNCTION chinook."TrackDurationSeconds";
DROP FUNCTION chinook."PlaylistStatistics";
DROP FUNCTION chinook."PlaylistStatisticsFor";

/* Let's create a query to look at Playlist statistics */
SELECT 
	p."PlaylistId", 
	p."Name" as "PlaylistName", 
	COUNT(t.*) as "NumberOfTracks", 
	CAST ( SUM ( CASE 
		WHEN t."Milliseconds" IS NOT NULL THEN t."Milliseconds" 
		ELSE 0 
	END ) AS FLOAT) / 1000.0 AS "DurationSeconds"
FROM
	chinook."Playlist" p
	LEFT OUTER JOIN chinook."PlaylistTrack" x
	ON p."PlaylistId" = x."PlaylistId"
	LEFT OUTER JOIN chinook."Track" t
	ON x."TrackId" = t."TrackId"
GROUP BY p."PlaylistId"
;

/* Let's use a built-in function to rewrite the Duration computation */
SELECT 
	p."PlaylistId", 
	p."Name" AS "PlaylistName", 
	COUNT(t.*) AS "NumberOfTracks", 
	SUM ( CAST ( COALESCE ( t."Milliseconds", 0.0 ) AS FLOAT ) / 1000.0 ) AS "DurationSeconds"
FROM
	chinook."Playlist" p
	LEFT OUTER JOIN chinook."PlaylistTrack" x
	ON p."PlaylistId" = x."PlaylistId"
	LEFT OUTER JOIN chinook."Track" t
	ON x."TrackId" = t."TrackId"
GROUP BY p."PlaylistId"
;

/* Duration is still a bit messy -- let's encapsulate that in a custom function. */
CREATE OR REPLACE FUNCTION chinook."TrackDurationSeconds" ( 
	IN "paramTrackMilliseconds" INTEGER,
	OUT "DurationSeconds" FLOAT
) RETURNS FLOAT AS $$
	SELECT CAST ( COALESCE( "paramTrackMilliseconds", 0.0 ) AS FLOAT ) / 1000.0	
$$ LANGUAGE 'sql' IMMUTABLE;

/* And now we can rewrite the query using this function */
SELECT 
	p."PlaylistId", 
	p."Name" AS "PlaylistName", 
	COUNT(t.*) AS "NumberOfTracks", 
	SUM ( chinook."TrackDurationSeconds"( t."Milliseconds") ) AS "DurationSeconds"
FROM
	chinook."Playlist" p
	LEFT OUTER JOIN chinook."PlaylistTrack" x
	ON p."PlaylistId" = x."PlaylistId"
	LEFT OUTER JOIN chinook."Track" t
	ON x."TrackId" = t."TrackId"
GROUP BY p."PlaylistId"
;

/* With a similar approach, we can get Playlist statistics with a single function call.
   Note that this is a choice -- since there are no input parameters, this is just as 
   well done in a view instead of a function.
*/
CREATE OR REPLACE FUNCTION chinook."PlaylistStatistics" ( ) RETURNS TABLE (
	"PlaylistId" INTEGER, 
	"PlaylistName" CHARACTER VARYING, 
	"NumberOfTracks" BIGINT, 
	"DurationSeconds" FLOAT
) AS $$
	SELECT 
		p."PlaylistId", 
		p."Name" AS "PlaylistName", 
		COUNT(t.*) AS "NumberOfTracks", 
		SUM ( chinook."TrackDurationSeconds"( t."Milliseconds") ) AS "DurationSeconds"
	FROM
		chinook."Playlist" p
		LEFT OUTER JOIN chinook."PlaylistTrack" x
		ON p."PlaylistId" = x."PlaylistId"
		LEFT OUTER JOIN chinook."Track" t
		ON x."TrackId" = t."TrackId"
	GROUP BY p."PlaylistId"
$$ LANGUAGE 'sql' STABLE;

/* And now our request for playlist statistics becomes a single line.*/
SELECT * FROM chinook."PlaylistStatistics"();

/* What if we wanted to get statistics about a single Playlist? Another function... */
CREATE OR REPLACE FUNCTION chinook."PlaylistStatisticsFor" (
	IN paramPlaylistId INTEGER
) RETURNS TABLE (
	"PlaylistId" INTEGER, 
	"PlaylistName" CHARACTER VARYING, 
	"NumberOfTracks" BIGINT, 
	"DurationSeconds" FLOAT
) AS $$
	SELECT 
		p."PlaylistId", 
		p."Name" AS "PlaylistName", 
		COUNT(t.*) AS "NumberOfTracks", 
		SUM ( chinook."TrackDurationSeconds"( t."Milliseconds") ) AS "DurationSeconds"
	FROM
		chinook."Playlist" p
		LEFT OUTER JOIN chinook."PlaylistTrack" x
		ON p."PlaylistId" = x."PlaylistId"
		LEFT OUTER JOIN chinook."Track" t
		ON x."TrackId" = t."TrackId"
	WHERE p."PlaylistId" = paramPlaylistId
	GROUP BY p."PlaylistId"
$$ LANGUAGE 'sql' STABLE;

SELECT * FROM chinook."PlaylistStatisticsFor"(15);
