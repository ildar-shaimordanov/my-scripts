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

For sure, you can modify all of them for your needs to filter excess data and query needful information only.

## See also

* https://gist.github.com/alexanderlz/7302623
* https://www.sqlshack.com/learn-sql-inner-join-vs-left-join/
* https://postgrespro.ru/docs/postgresql/9.5/catalogs
  * https://postgrespro.ru/docs/postgresql/9.5/catalog-pg-attribute
  * https://postgrespro.ru/docs/postgresql/9.5/catalog-pg-class
  * https://postgrespro.ru/docs/postgresql/9.5/catalog-pg-description
  * https://postgrespro.ru/docs/postgresql/9.5/view-pg-tables

# Appendix 1: Export data to LibreOffice

## Step by step procedure

1. Place the `pg-describe.sh` and `pg-describe.sql` files.
2. Give the execution permission for the first one
3. Run it to collect what you want in TAB separated file (TSV)
4. Insert each resulting file as a separate LibreOffice sheet

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
