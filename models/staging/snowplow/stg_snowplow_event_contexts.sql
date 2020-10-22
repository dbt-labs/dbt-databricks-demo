with parsed as (

    select

        event_id,
        collector_tstamp,
        from_json(contexts, 'schema string, data array<struct<data:varchar(65000),schema:string>>') as contexts
        
    from {{ ref('stg_snowplow_events') }}

),

flattened as (

    select *,
    
        explode(contexts['data']) as ctxt

    from parsed

),

unnested as (

    select

        event_id,
        collector_tstamp,
        ctxt['schema'] as ctxt_schema,
        ctxt['data'] as ctxt_data

    from flattened

)

select * from unnested
