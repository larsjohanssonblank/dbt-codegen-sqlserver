{% macro assert_equal(actual_object, expected_object) %}
{% if not execute %}

    {# pass #}

{% elif object_1 != object_2 %}

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
{% endmacro %}
