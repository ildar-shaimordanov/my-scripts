#!/usr/bin/env bash

# =========================================================================
#
# Copyright (C) 2024 Ildar Shaimordanov
# MIT License
#
# =========================================================================

./pg-describe.sh \
"where table_schema not in ( 'information_schema', 'pg_catalog', 'pg_toast', 'public' )"
