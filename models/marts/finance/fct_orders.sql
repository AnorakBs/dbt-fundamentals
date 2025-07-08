{#{
    config(
        materialized='incremental'
    )
}#}

with 

orders as (
    select * from {{ ref('stg_orders') }}
),

payment as (
    select * from {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        sum (case when status = 'success' then amount end) as amount
    from payment
    group by 1

),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(order_payments.amount, 0) as amount
    from orders
    left join order_payments on order_payments.order_id = orders.order_id
)

select * from final
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where order_date >= (select max(order_date) from {{ this }}) 
{% endif %}
order by order_date desc