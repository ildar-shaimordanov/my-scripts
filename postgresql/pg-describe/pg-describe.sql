-- Copyright (C) 2023, 2024 Ildar Shaimordanov
-- MIT License
with all_descriptions as (
  select
      pn.nspname as table_schema
    , null::text as table_name
    , null::int8 as n
    , null::text as column_name
    , null::text as column_type
    , null::text as nullable
    , null::text as default
    , pd.description as comment
  from pg_catalog.pg_namespace pn
  left join pg_catalog.pg_description pd
    on pd.objoid = pn.oid
union all
  select
      t.table_schema
    , t.table_name
    , null::int8 as n
    , null::text as column_name
    , null::text as column_type
    , null::text as nullable
    , null::text as default
    , pd.description as comment
  from pg_catalog.pg_class pc
  left join information_schema.tables t
    on t.table_name = pc.relname
  left join pg_catalog.pg_description pd
    on pd.objoid = pc.oid
    and pd.objsubid = 0
  where pc.relkind = 'r'
union all
  select
      c.table_schema
    , c.table_name
    , pa.attnum as n
    , pa.attname as column_name
    , case
      when numeric_precision is not null
      then format('%s (%s, %s)', data_type, numeric_precision, numeric_scale)
      when character_maximum_length is not null
      then format('%s (%s)', data_type, character_maximum_length)
      else data_type
      end as column_type
    , c.is_nullable as nullable
    , c.column_default as default
    , pd.description as comment
  from pg_catalog.pg_class pc
  left join pg_catalog.pg_attribute pa
    on pa.attrelid = pc.oid
    and not pa.attisdropped
    and pa.attnum > 0
  left join pg_catalog.pg_description pd
    on pd.objoid = pc.oid
    and pd.objsubid = pa.attnum
  left join information_schema.columns c
    on c.table_name = pc.relname
    and c.ordinal_position = pa.attnum
  where pc.relkind = 'r'
)
select *
from all_descriptions ad
where table_schema = 'public' -- !!! -- project-related
order by table_schema, table_name nulls first, n nulls first
