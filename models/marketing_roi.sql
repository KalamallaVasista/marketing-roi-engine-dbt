with ad_spend as (
    select * from {{ ref('stg_ad_spend') }}
),

sessions as (
    select * from {{ ref('stg_sessions') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- 1. Link transactions to sessions to attribute revenue to platforms and campaigns
attributed_revenue as (
    select 
        s.date,
        s.platform,
        s.campaign,
        sum(t.revenue) as total_revenue
    from sessions s
    left join transactions t 
        on s.user_id = t.user_id 
        and s.date = t.date
    group by 1, 2, 3
)

-- 2. Join the attributed revenue with ad spend to calculate ROI
select 
    a.date,
    a.platform,
    a.campaign,
    a.clicks,
    a.spend,
    coalesce(r.total_revenue, 0) as revenue,
    coalesce(r.total_revenue, 0) - a.spend as profit,
    case 
        when a.spend > 0 then (coalesce(r.total_revenue, 0) - a.spend) / a.spend 
        else 0 
    end as roi_percentage
from ad_spend a
left join attributed_revenue r
    on a.date = r.date
    and a.platform = r.platform
    and a.campaign = r.campaign