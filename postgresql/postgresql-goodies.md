# How to connect from CLI

Create and configure a password file:

~~~shell
cat <<! > ~/.pgpass
# hostname:port:database:username:password
*:*:*:postgres_username:postgres_password
!
~~~

~~~shell
chmod 600 ~/.pgpass
~~~

Update a bash profile file:

~~~shell
grep -q 'export PG' ~/.bashrc || cat <<! >> ~/.bashrc
# PostgreSQL settings
export PGDATABASE="postgres"
export PGHOST="localhost"
export PGUSER="postgres_username"
alias psql="LESS='-S' psql"
!
~~~

Replace `postgres_username` and `postgres_password` with the real values.

__Links__

* https://www.postgresql.org/docs/current/libpq-pgpass.html
* https://www.postgresql.org/docs/current/libpq-envars.html
