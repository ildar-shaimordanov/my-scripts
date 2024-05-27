# Preamble

It's my attempt to extract all the project-related stuff: tables, columns, their definitions and descriptions.

I'm not postgresql guru, so I spent a lot of hours during a few days to invent the approach giving the applicable result.

# Explanation

There is final version. You can find it as a separate file below. I found and fixed all my errors from previous attempts and made some improvements in sorting tables and columns names correctly (a table name first, then its column names and so on). Also I added querying schemas and their descriptions. It works as expected. I am not 100% sure in its performance and optimality but I am not going use it frequently.

## Querying

This outer WHERE-clause is very common and is used to collect the project-related things and leave the Postgres-specific stuff out of the filter:

```sql
where table_schema = 'public'
```

This clause is used to query all the tables underlying the schemas named specifically:

```sql
where table_schema like '%sm'
```

Another one is used to extract requested data for all tables in the `public` schema but one:

```sql
where table_schema = 'public' and table_name is distinct from 'alembic_version'
```

Here is one more query which is a little bit more complicated (to skip any service tables used in PostgreSQL):

```sql
where table_schema not in ( 'information_schema', 'pg_catalog', 'pg_toast', 'public' )
```

... and so on.

For sure, you can modify all of them for your needs to filter excess data and query needful information only. Also you can find `pg-describe*.sh` scripts that simplify and automate this action.

# Appendix 1: Export data to LibreOffice

## Prerequisites

* psql
* bash

It's assumed that psql is executed under a configured user (using the `PGUSER` variable with friends and `~/.pgpass` file).

## Step by step procedure

1. Place the `pg-describe.sh` and `pg-describe.sql` files.
2. Give the execution permission for the first one
3. Run it to collect what you want in TAB separated files (TSV)
4. Insert each resulting file as a separate LibreOffice sheet

## Actions in LibreOffice

Add TSV files as sheets

* En: Sheet | Insert Sheet | From file | Browse
* Ru: Лист | Вставить лист | Из файла | Обзор

Turn autofilter

* En: Data | AutoFilter
* Ru: Данные | Автофильтр

Freeze headers

* En: View | Freeze Cells | Freeze First Row
* Ru: Вид | Фиксировать ячейки | Фиксировать первую строку

# Appendix 2: Export data to MS Excel

## Prerequisites

* https://github.com/dbeaver/dbeaver
* https://github.com/ildar-shaimordanov/jsxt

## Step by step procedure

1. Launch Dbeaver and connect to the server
2. Run the  `pg-describe.sql` script in Dbeaver
3. Export data to some XMLFILE
4. Run the command `wsx pg-describe.js XMLFILE > HTMLFILE`
5. Open HTMLFILE in a browser or Excel

## The "pg-describe.js" script algorithm

1. Load the exported XML file
2. Transform to another XML
3. Load `pg-describe.xsd`
4. Validate the new XML
5. Load `pg-describe.xsl`
6. Transform XML to HTML

# Appendix 3: Documentation

* https://gist.github.com/alexanderlz/7302623
* https://www.sqlshack.com/learn-sql-inner-join-vs-left-join/
* https://postgrespro.com/docs/postgresql/current/catalogs
  * https://postgrespro.com/docs/postgresql/current/catalog-pg-attribute
  * https://postgrespro.com/docs/postgresql/current/catalog-pg-class
  * https://postgrespro.com/docs/postgresql/current/catalog-pg-description
  * https://postgrespro.com/docs/postgresql/current/view-pg-tables
* https://postgrespro.com/docs/postgresql/current/libpq-envars
* https://postgrespro.com/docs/postgresql/current/libpq-pgpass

