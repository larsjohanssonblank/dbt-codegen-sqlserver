{% macro get_tables_in_schema(schema_name, database_name=target.database) %}

    {% set tables=get_tables_by_prefix_sqlserver(
            schema=schema_name,
            prefix='',
            database=database_name
        )
    %}

    {% set table_list= tables | map(attribute = 'identifier') %}

    {{ return(table_list | sort) }}
    {{ log("*** table list ***", info=True) }}
    {{ log(table_list, info=True) }}

{% endmacro %}

{% macro get_columns_in_relation_sqlserver(relation, database=target.database) -%}
  {% call statement('get_columns_in_relation_sqlserver', fetch_result=True) %}
                SELECT
          column_name,
          data_type,
          character_maximum_length,
          numeric_precision,
          numeric_scale
      FROM
          (select
              ordinal_position,
              column_name,
              data_type,
              character_maximum_length,
              numeric_precision,
              numeric_scale
          from {{database}}.INFORMATION_SCHEMA.COLUMNS
          where table_name = '{{ relation.identifier }}'
            and table_schema = '{{ relation.schema }}') cols
          order by ordinal_position
  {% endcall %}
  {% set table = load_result('get_columns_in_relation_sqlserver').table %}
  {{ return(sql_convert_columns_in_relation(table)) }}
{% endmacro %}

{% macro get_tables_by_prefix_sqlserver(schema, prefix, exclude='', database=target.database) %}

    {%- call statement('get_tables', fetch_result=True) %}

      {{ get_tables_by_prefix_sql_sqlserver(schema, prefix, exclude, database) }}

    {%- endcall -%}

    {%- set table_list = load_result('get_tables') -%}

    {%- if table_list and table_list['table'] -%}
        {%- set tbl_relations = [] -%}
        {%- for row in table_list['table'] -%}
            {%- set tbl_relation = api.Relation.create(database, row.table_schema, row.table_name) -%}
            {%- do tbl_relations.append(tbl_relation) -%}
        {%- endfor -%}
                
        {{ return(tbl_relations) }}
    {%- else -%}
        {{ return([]) }}
    {%- endif -%}
    
{% endmacro %}

{% macro get_tables_by_prefix_sql_sqlserver(schema, prefix, exclude='', database=target.database) %}
            select distinct 
            table_schema as "table_schema", table_name as "table_name"
        from {{database}}.information_schema.tables
        where table_schema like '{{ schema }}'
        and table_name like lower ('{{prefix}}%')
        and table_name not like lower ('{{exclude}}')
{% endmacro %}

---
{% macro generate_source_sqlserver(schema_name, database_name=target.database, generate_columns=False) %}

{% set sources_yaml=[] %}

{% do sources_yaml.append('version: 2') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('sources:') %}
{% do sources_yaml.append('  - name: ' ~ schema_name) %}
{% do sources_yaml.append('    tables:') %}

{% set tables=get_tables_in_schema(schema_name, database_name) %}

{% for table in tables %}
    {% do sources_yaml.append('      - name: ' ~ table ) %}
    {% do sources_yaml.append('        identifier: ' ~ table) %}

    {% if generate_columns %}
    {% do sources_yaml.append('        columns:') %}

        {% set table_relation=api.Relation.create(
            database=database_name,
            schema=schema_name,
            identifier=table
        ) %}

        {% set columns=get_columns_in_relation_sqlserver(table_relation, database_name) %}

        {% for column in columns %}
            {% do sources_yaml.append('          - name: ' ~ column.name) %}
        {% endfor %}
            {% do sources_yaml.append('') %}

    {% endif %}

{% endfor %}

{% if execute %}

    {% set joined = sources_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
