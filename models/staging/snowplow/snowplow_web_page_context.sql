{{ config(
    materialized = 'incremental',
    unique_key = 'root_id'
) }}

with contexts as (

    select * from {{ ref('stg_snowplow_event_contexts') }}
    where ctxt_schema like '%web_page%'
    
    {% if is_incremental() %}
        and collector_tstamp > (select max(max_collector_tstamp) as max_tstamp from {{ this }})
    {% endif %}

),

prep as (

    select

        event_id as root_id,
        cast(from_json(ctxt_data, 'id varchar(64)')['id'] as varchar(64)) as page_view_id,
        max(collector_tstamp) as max_collector_tstamp

    from contexts
    group by 1,2

),

duplicated as (

    select
        root_id

    from prep
    group by 1
    having count(*) > 1

)

select * from prep where root_id not in (select root_id from duplicated)
