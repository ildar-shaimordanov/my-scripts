#!/usr/bin/env bash

# =========================================================================
#
# Copyright (C) 2024 Ildar Shaimordanov
# MIT License
#
# =========================================================================

./pg-describe.sh \
"where table_schema = 'public' and table_name is distinct from 'alembic_version'"
