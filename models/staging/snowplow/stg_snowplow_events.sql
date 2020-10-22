select

  approximateArrivalTimestamp as approx_arrival_tstamp,

  {% set snowplow_event_columns = graph.sources.values()
    | selectattr('unique_id', 'equalto', 'source.dbt_databricks_demo.snowplow.event')
    | map(attribute = 'columns') 
    | list %}

  {% for column in snowplow_event_columns[0].values() %}

    cast(split(data,'\t')[{{ loop.index0 }}] as {{ column.data_type }}) as {{ column.name }}
    {{- "," if not loop.last -}}

  {% endfor %}

from {{ source('snowplow', 'event') }}
