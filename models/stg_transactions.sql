with raw_transactions as (
    select * 
    from `marketing-roi-engine.raw_data.transactions`
),

deduped as (
    select *
    from raw_transactions
    -- This keeps only the first instance of each transaction_id
    qualify row_number() over (partition by transaction_id order by date desc) = 1
)

select * 
from deduped