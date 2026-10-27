with raw_sessions as (
    select * 
    from `marketing-roi-engine.raw_data.sessions`
),

deduped as (
    select *
    from raw_sessions
    -- This keeps only the first instance of each session_id
    qualify row_number() over (partition by session_id order by date desc) = 1
)

select * 
from deduped