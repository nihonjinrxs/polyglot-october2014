/***************************************
  Polyglot Programming DC : October 2014
  Manipulating Data in Style with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-08-02
  **************************************
  This script inspects the various 
  tables in the Chinook database and 
  returns their row counts.
****************************************/

/* Count of rows in all tables of Chinook database */
select 'Album' as tablename, count(*) as numrows from chinook."Album"
union all
select 'Artist' as tablename, count(*) as numrows from chinook."Artist"
union all
select 'Customer' as tablename, count(*) as numrows from chinook."Customer"
union all
select 'Employee' as tablename, count(*) as numrows from chinook."Employee"
union all
select 'Genre' as tablename, count(*) as numrows from chinook."Genre"
union all
select 'Invoice' as tablename, count(*) as numrows from chinook."Invoice"
union all
select 'InvoiceLine' as tablename, count(*) as numrows from chinook."InvoiceLine"
union all
select 'MediaType' as tablename, count(*) as numrows from chinook."MediaType"
union all
select 'Playlist' as tablename, count(*) as numrows from chinook."Playlist"
union all
select 'PlaylistTrack' as tablename, count(*) as numrows from chinook."PlaylistTrack"
union all
select 'Track' as tablename, count(*) as numrows from chinook."Track"
;
