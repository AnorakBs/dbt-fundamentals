select 
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    amount/ 100 as amount, -- stored as cents, convert it to dollar
    created,
    _batched_at

from {{ source('stripe', 'payment') }}
