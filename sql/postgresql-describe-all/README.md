# Preamble

It's my attempt to extract all the project-related tables, columns and their descriptions.

I'm not postgresql guru, so I spent a lot of hours during a few days to invent the approach giving the applicable result.

# Explanation

There is final version. You can find it as a separate file below. I found and fixed all my errors from previous attempts and made some improvements in sorting tables and columns names correctly (a table name first, then its column names and so on). Also I added querying schemas and their descriptions. It works as expected. I am not 100% sure in its performance and optimality but I am not going use it frequently.

The `where table_schema like '%sm'` clause is used to query my project-related stuff. It should be adjusted to specify uniquely your project stuff only. Probably, depending on the model of your project, the last `where`-clause should be modified. For example, if all your tables were created within the `public` schema, the query can look like:

```sql
where table_schema = 'public'
```

or a little bit more complicated (to skip any service tables used in PostgreSQL)

```sql
where table_schema not in ( 'information_schema', 'pg_catalog', 'pg_toast', 'public' )
```

and so on.

For sure, you can modify all of them for your needs to filter excess data and query needful information only.

# See also

* https://gist.github.com/alexanderlz/7302623
* https://www.sqlshack.com/learn-sql-inner-join-vs-left-join/
* https://postgrespro.ru/docs/postgresql/9.5/catalogs
  * https://postgrespro.ru/docs/postgresql/9.5/catalog-pg-attribute
  * https://postgrespro.ru/docs/postgresql/9.5/catalog-pg-class
  * https://postgrespro.ru/docs/postgresql/9.5/catalog-pg-description
  * https://postgrespro.ru/docs/postgresql/9.5/view-pg-tables

# Appendix 1

## Prerequisites

* https://github.com/dbeaver/dbeaver
* https://github.com/ildar-shaimordanov/jsxt

## Step by step procedure

1. Launch Dbeaver and connect to the server
2. Run the  `describe-all.sql` script in Dbeaver
3. Export data to some XMLFILE
4. Run the command `wsx describe-all.js XMLFILE > HTMLFILE`
5. Open HTMLFILE in a browser or Excel

## The "describe-all.js" script algorithm

1. Load the exported XML file
2. Transform to another XML
3. Load `describe-all.xsd`
4. Validate the new XML
5. Load `describe-all.xsl`
6. Transform XML to HTML
