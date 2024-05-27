#!/usr/bin/env bash

./pg-describe.sh \
"where table_schema not in ( 'information_schema', 'pg_catalog', 'pg_toast', 'public' )"
