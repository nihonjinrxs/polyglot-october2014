# Manipulating Data in Style with SQL
##### An introduction to SQL, the interface language to most of the world’s structured data, and practices for readable and reusable SQL code

This repository contains materials for [my talk at the Polyglot Programming DC meetup on October 14, 2014](http://www.meetup.com/Polyglot-Programming-DC/events/208670052/), which is loosely based on material from my talks at the Data Wranglers DC meetups on [June 4, 2014](http://www.meetup.com/Data-Wranglers-DC/events/171768162/) ([materials at nihonjinrxs/dwdc-june2014](http://www.github.com/nihonjinrxs/dwdc-june2014)) and [August 6, 2014](http://www.meetup.com/Data-Wranglers-DC/events/177269432/) ([materials at nihonjinrxs/dwdc-august2014](http://www.github.com/nihonjinrxs/dwdc-august2014)).

### Contents
The talk consists of two major directions:
- An introduction to SQL and relational databases, and techniques for writing readable and reusable code in SQL
- Using SQL on Data Frame objects in R and Python

Folders are as follows:
- A slide deck (`./slides`) in Apple Keynote, [PDF](http://nihonjinrxs.github.io/polyglot-october2014/Polyglot-October2014-RyanHarvey.pdf) and [HTML](http://nihonjinrxs.github.io/polyglot-october2014) formats
- A set of SQL scripts (`./sql`) that demonstrate the queries discussed, as well as the creation of database objects such as views and functions
- An RMarkdown document (`./R`), [published on RPubs](http://rpubs.com/ryanbharvey/polyglot-october2014), that demonstrates using `sqldf` in R to perform SQL queries on data frames as if they are tables
- An IPython notebook (`./python`), [available at IPython nbviewer](http://nbviewer.ipython.org/github/nihonjinrxs/polyglot-october2014/blob/master/python/sqldf_examples_python.ipynb), that demonstrates using `sqldf` from the `pandasql` package to perform SQL queries on Pandas DataFrame objects as if they are tables

### Where do I start?
I recommend that anyone wishing to understand what I've done should tackle these pieces in order, starting with the slide deck.  In order to work with the code examples, you'll need [PostgreSQL](http://www.postgresql.org/) (I used version 9.3 on an Apple Mac to create these examples) and the [Chinook Database](http://chinookdatabase.codeplex.com/) ([MS-PL licensed](http://chinookdatabase.codeplex.com/license)).  You may also want to review the [Chinook data model and schema](http://chinookdatabase.codeplex.com/wikipage?title=Chinook_Schema&referringTitle=Home).

### Importing the Chinook data into PostgreSQL
Once you download the Chinook Database and unzip the file, you'll see a collection of scripts.  You're looking for the `Chinook_PostgreSql.sql` file.  If you just run the SQL file from the `psql` command prompt, PostgreSQL will happily dump the database objects into your public schema.  I prefer to have a named schema, and the examples here assume one.  In order to do that, you'll need to do a few more steps:

```
psql> CREATE SCHEMA "chinook";
psql> SET search_path TO chinook;
psql> \i /path/to/script/Chinook_PostgreSql.sql
```

Note that many of the SQL examples using the Chinook database depend on a faulty import of Chinook data that doesn't take into account character set issues, and thus leaves out many records in tables.  Although we would normally not want this to happen, doing it intentionally here provides some interesting real-world data integrity problems to inspect, so I've done this on purpose.  A log of the import process with errors and warnings ([`chinook_import.log`](https://github.com/nihonjinrxs/polyglot-october2014/blob/master/sql/chinook_import.log))is provided in the `.sql` directory, so that one can manually achieve an identical result if desired (although the examples should work with any non-zero number of import errors in the specified tables, so long as some data is actually imported).

### Disclaimer
This work and the opinions expressed here are my own, and do not purport to represent the views of my current or former employers.

The MIT license on this repo covers all contents of the repo, but does not supercede the existing licenses for products used for this work, including PostgreSQL (covered by the [PostgreSQL License](http://www.postgresql.org/about/licence/)) and the Chinook Database (covered by the [Microsoft Public License](http://chinookdatabase.codeplex.com/license)).

