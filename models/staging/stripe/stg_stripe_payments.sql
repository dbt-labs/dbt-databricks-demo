with source_payments as (

    select * from {{ source('stripe', 'payments') }}

),

renamed_payments as (

    select
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,

        -- amount is stored in cents, convert it to dollars
        amount / 100 as amount,
        created as created_at

    from source_payments

)

select * from renamed_payments
