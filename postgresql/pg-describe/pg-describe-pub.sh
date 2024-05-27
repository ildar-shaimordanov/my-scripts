#!/usr/bin/env bash

./pg-describe.sh \
"where table_schema = 'public' and table_name is distinct from 'alembic_version'"
