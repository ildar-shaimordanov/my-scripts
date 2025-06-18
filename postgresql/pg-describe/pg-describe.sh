#!/usr/bin/env bash

# =========================================================================
#
# Describe all the project-related tables, columns and their descriptions
#
# Copyright (C) 2024, 2025 Ildar Shaimordanov
# MIT License
#
# =========================================================================

set -o errexit

PG_DESC_ORIG="$( dirname "$0" )/pg-describe.sql"
PG_DESC_FILE="$PG_DESC_ORIG"

PG_SHOW_DATABASES="\
select datname
from pg_database
where datname not in ( 'postgres', 'template0', 'template1', 'template_rbac' )"

# =========================================================================

# Provide the WHERE clause to filter the project-related stuff only

[ $# -gt 0 ] && {
	PG_DESC_FILE="${TMP:-/tmp}/pg-describe-$$.sql"
	trap 'rm "$PG_DESC_FILE"' EXIT

	awk -v WHERE="$*" '/-- !!! --/ { $0 = WHERE } 1' \
	< "$PG_DESC_ORIG" \
	> "$PG_DESC_FILE"
}

# =========================================================================

# Filter the user-defined databases and collect all the descriptions
# per each database in separate files

psql -At -c "$PG_SHOW_DATABASES" \
| while read -r db
do
	psql --pset footer=off -AF $'\t' -f "$PG_DESC_FILE" "$db" \
	> "pg-describe-$db.tsv"
done

# =========================================================================

# EOF
