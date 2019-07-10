
{% set raw_schema = generate_schema_name('raw_data') %}

{% set source = codegen.generate_source(
    schema_name=raw_schema,
    database_name=target.database,
    generate_columns=True
) %}
