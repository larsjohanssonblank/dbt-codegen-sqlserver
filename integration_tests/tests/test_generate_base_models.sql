
{% set base_model = codegen.generate_base_model(
    source_name='codegen_integration_tests__data_source_schema',
    table_name='codegen_integration_tests__data_source_table'
  )
%}

{% set expected %}
with source as (

    select * from {%raw%}{{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table') }}{%endraw%}

),

renamed as (

    select
        my_integer_col,
        my_bool_col

    from source

)

select * from renamed
{% endset %}

{% if not execute %}

    {# pass #}

{% elif (base_model | trim) != (expected | trim) %}

    {% set msg %}
    Expected did not match actual

    -----------
    Expected:
    -----------
    --->{{ expected | trim }}<---

    -----------
    Actual:
    -----------
    --->{{ base_model | trim }}<---

    {% endset %}

    {% do exceptions.raise_compiler_error(msg) %}

{% else %}

    select 'ok' limit 0

{% endif %}
