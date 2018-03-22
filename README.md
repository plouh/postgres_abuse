## How to implement no-code REST API with PostgreSQL

This repository contains source code for the presentation on 20th of November at [Talented](https://talented.fi)

To run these examples, check out either [talented_session](https://github.com/plouh/postgres_abuse/tree/talented_session) or
[example_session](https://github.com/plouh/postgres_abuse/tree/example_solution) branch and follow the instructions:

#### First start the associated docker container

    ➜  postgres git:(talented_session) ✗ (cd docker && docker-compose up &)
    Starting docker_database_1 ... done
    Starting docker_api_1 ... done
    Attaching to docker_database_1, docker_api_1
    database_1  | 2018-03-22 17:42:55.863 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
    database_1  | 2018-03-22 17:42:55.863 UTC [1] LOG:  listening on IPv6 address "::", port 5432
    api_1       | Listening on port 3000
    api_1       | Attempting to connect to the database...
    database_1  | 2018-03-22 17:42:55.867 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
    api_1       | Attempting to reconnect to the database in 0 seconds...
    api_1       | {"details":"FATAL:  database \"ontrail\" does not exist\n","code":"","message":"Database connection error"}
    database_1  | 2018-03-22 17:42:56.170 UTC [1] LOG:  database system is ready to accept connections
    database_1  | 2018-03-22 17:42:56.361 UTC [25] FATAL:  database "ontrail" does not exist
    database_1  | 2018-03-22 17:42:57.368 UTC [26] FATAL:  database "ontrail" does not exist
    api_1       | {"details":"FATAL:  database \"ontrail\" does not exist\n","code":"","message":"Database connAttempting to reconnect to the database in 1 seconds...

#### Next, connect to postgres and create the database

    ➜  postgres git:(talented_session) ✗ psql -U postgres -h localhost
    psql (10.3)
    Type "help" for help.

    postgres=# create database ontrail;
    CREATE DATABASE
    postgres=#

#### Check that api container can connect to the database

docker logs at console should look like this:

    api_1       | Attempting to reconnect to the database in 32 seconds...
    database_1  | 2018-03-22 17:58:06.133 UTC [28] FATAL:  role "ontrail_authenticator" does not exist
    api_1       | {"details":"FATAL:  role \"ontrail_authenticator\" does not exist\n","code":"","message":"Database connection error"}
    api_1       | Attempting to reconnect to the database in 32 seconds...

Ok, so we are missing some roles in the database.

I strongly recommend using VSCode and its `pgsql-html` -extension for the
remaining tasks.  You can use `SHIFT+F5` to execute commands directly from
sql-files to make things go faster.

In addition, you need to add the connection string to workspace settings in order for `pgsql`-extension to be able to connect to the database.

    {
      "settings": {
        "pgsql.connection": "postgres://postgres@localhost:5432/ontrail"
      }
    }

Next, run the sql scripts in following order:

- `database/create_database.sql`
- `database/ontrail_private/users.sql`
- `database/ontrail_private/auth.sql`
- `database/ontrail/sport.sql`
- `database/ontrail/exercise.sql`
- `database/ontrail/comments.sql`
- `database/ontrail/feed.sql`

The demo should now be set up and you can start using the rest api.
You'll find the swagger documentation at [http://localhost:3000/]().

Happy hacking!


P.S. If you want to test some speed typing, there are some snippets at pgsql.json that you can install to VS Code as snippets for your pleasure. :)