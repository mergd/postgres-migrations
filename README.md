# db-migrations

Example repo of a declarative database migration system for Postgres.


Make sure you have [`Rye`](https://rye.astral.sh/guide/) and Postgres installed.

Run `sh scripts/generateMigrations.sh <name>` to generate a migration file.


Copy and paste your initial schema in `init_snapshot.sql` and `init.sql`. 

Make changes to `init.sql` and run the script to generate migrations.
