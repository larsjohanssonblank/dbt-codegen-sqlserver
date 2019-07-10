
{% set raw_schema = generate_schema_name('raw_data') %}

-- test default args
{% set source = codegen.generate_source(raw_schema) %}

{% set expected %}

... add expected here ..

{% endset %}


... compare actual to expected here ...
