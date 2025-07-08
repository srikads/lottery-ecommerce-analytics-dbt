{% macro query_results(model_name) %}
    {% set query %}
        SELECT * FROM {{ ref(model_name) }} LIMIT 10
    {% endset %}
    
    {% do run_query(query) %}
{% endmacro %} 