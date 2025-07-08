
  
    
    
    create  table main."int_identity_stitching"
    as
        -- Identity Stitching Model
-- This model unifies anonymous and authenticated users for complete customer journey tracking

with anonymous_events as (
    select 
        event_id,
        anonymous_user_id,
        utm_campaign,
        event_timestamp,
        'anonymous' as user_type
    from main."stg_web_events"
    where user_id is null 
    and anonymous_user_id is not null
),

authenticated_events as (
    select 
        event_id,
        user_id,
        utm_campaign,
        event_timestamp,
        'authenticated' as user_type
    from main."stg_web_events"
    where user_id is not null
),

-- Find potential matches between anonymous and authenticated users
-- Based on UTM campaign and timing proximity
potential_matches as (
    select 
        ae.anonymous_user_id,
        aue.user_id,
        ae.utm_campaign,
        ae.event_timestamp as anonymous_timestamp,
        aue.event_timestamp as authenticated_timestamp,
        julianday(aue.event_timestamp) - julianday(ae.event_timestamp) as time_difference_days,
        
        -- Scoring for match confidence
        case 
            when ae.utm_campaign = aue.utm_campaign then 3  -- Same campaign
            else 0
        end +
        case 
            when abs(julianday(aue.event_timestamp) - julianday(ae.event_timestamp)) <= 1 then 2  -- Within 1 day
            when abs(julianday(aue.event_timestamp) - julianday(ae.event_timestamp)) <= 7 then 1  -- Within 1 week
            else 0
        end as match_score
        
    from anonymous_events ae
    cross join authenticated_events aue
    where ae.utm_campaign = aue.utm_campaign  -- Must have same campaign
    and abs(julianday(aue.event_timestamp) - julianday(ae.event_timestamp)) <= 30  -- Within 30 days
),

-- Select best matches for each anonymous user
best_matches as (
    select 
        anonymous_user_id,
        user_id,
        utm_campaign,
        anonymous_timestamp,
        authenticated_timestamp,
        time_difference_days,
        match_score,
        row_number() over (partition by anonymous_user_id order by match_score desc, time_difference_days asc) as match_rank
    from potential_matches
    where match_score >= 3  -- Minimum confidence threshold
),

-- Confirmed identity mappings
identity_mappings as (
    select 
        anonymous_user_id,
        user_id,
        utm_campaign,
        anonymous_timestamp,
        authenticated_timestamp,
        time_difference_days,
        match_score,
        'confirmed' as mapping_status
    from best_matches
    where match_rank = 1
),

-- Complete user journey with identity stitching
unified_user_journey as (
    select 
        coalesce(im.user_id, ae.user_id) as unified_user_id,
        ae.event_id,
        null as anonymous_user_id,
        ae.user_id as original_user_id,
        ae.utm_campaign,
        ae.event_timestamp,
        ae.user_type,
        im.mapping_status,
        im.match_score,
        
        -- Journey stage
        case 
            when im.mapping_status = 'confirmed' and ae.user_type = 'anonymous' then 'pre_signup'
            when im.mapping_status = 'confirmed' and ae.user_type = 'authenticated' then 'post_signup'
            when ae.user_type = 'authenticated' then 'authenticated_only'
            else 'anonymous_only'
        end as journey_stage,
        
        -- Time relative to signup (if available)
        case 
            when im.user_id is not null and s.signup_timestamp is not null 
            then julianday(ae.event_timestamp) - julianday(s.signup_timestamp)
            else null
        end as days_relative_to_signup
        
    from authenticated_events ae
    left join identity_mappings im on ae.user_id = im.user_id
    left join main."stg_signups" s on coalesce(im.user_id, ae.user_id) = s.user_id
    
    union all
    
    select 
        coalesce(im.user_id, ane.anonymous_user_id) as unified_user_id,
        ane.event_id,
        ane.anonymous_user_id,
        null as original_user_id,
        ane.utm_campaign,
        ane.event_timestamp,
        ane.user_type,
        im.mapping_status,
        im.match_score,
        
        -- Journey stage
        case 
            when im.mapping_status = 'confirmed' then 'pre_signup'
            else 'anonymous_only'
        end as journey_stage,
        
        -- Time relative to signup (if available)
        case 
            when im.user_id is not null and s.signup_timestamp is not null 
            then julianday(ane.event_timestamp) - julianday(s.signup_timestamp)
            else null
        end as days_relative_to_signup
        
    from anonymous_events ane
    left join identity_mappings im on ane.anonymous_user_id = im.anonymous_user_id
    left join main."stg_signups" s on im.user_id = s.user_id
),

-- User journey summary
user_journey_summary as (
    select 
        unified_user_id,
        min(event_timestamp) as first_touch_timestamp,
        max(event_timestamp) as last_touch_timestamp,
        count(*) as total_events,
        count(distinct utm_campaign) as unique_campaigns,
        count(distinct case when journey_stage = 'pre_signup' then event_id end) as pre_signup_events,
        count(distinct case when journey_stage = 'post_signup' then event_id end) as post_signup_events,
        count(distinct case when journey_stage = 'anonymous_only' then event_id end) as anonymous_only_events,
        
        -- Campaign journey
        group_concat(utm_campaign, ', ') as campaign_journey,
        
        -- Identity resolution
        max(case when mapping_status = 'confirmed' then 1 else 0 end) as has_identity_resolution,
        max(match_score) as max_match_score,
        
        -- Timing metrics
        min(days_relative_to_signup) as earliest_event_days_from_signup,
        max(days_relative_to_signup) as latest_event_days_from_signup,
        
        -- Journey completeness
        case 
            when count(distinct case when journey_stage = 'pre_signup' then event_id end) > 0 
                 and count(distinct case when journey_stage = 'post_signup' then event_id end) > 0 
            then 'Complete Journey'
            when count(distinct case when journey_stage = 'pre_signup' then event_id end) > 0 
            then 'Pre-signup Only'
            when count(distinct case when journey_stage = 'post_signup' then event_id end) > 0 
            then 'Post-signup Only'
            else 'Anonymous Only'
        end as journey_completeness
        
    from unified_user_journey
    group by unified_user_id
)

select 
    -- User identification
    ujs.unified_user_id,
    ujs.has_identity_resolution,
    ujs.max_match_score,
    
    -- Journey metrics
    ujs.first_touch_timestamp,
    ujs.last_touch_timestamp,
    ujs.total_events,
    ujs.unique_campaigns,
    ujs.pre_signup_events,
    ujs.post_signup_events,
    ujs.anonymous_only_events,
    
    -- Campaign information
    ujs.campaign_journey,
    
    -- Timing information
    ujs.earliest_event_days_from_signup,
    ujs.latest_event_days_from_signup,
    
    -- Journey classification
    ujs.journey_completeness,
    
    -- Identity resolution quality
    case 
        when ujs.max_match_score >= 5 then 'High Confidence'
        when ujs.max_match_score >= 3 then 'Medium Confidence'
        else 'Low Confidence'
    end as identity_resolution_confidence,
    
    -- Journey value indicators
    case 
        when ujs.total_events >= 10 then 'High Engagement'
        when ujs.total_events >= 5 then 'Medium Engagement'
        when ujs.total_events >= 2 then 'Low Engagement'
        else 'Single Touch'
    end as engagement_level,
    
    current_timestamp as dbt_updated_at

from user_journey_summary ujs
order by ujs.total_events desc, ujs.max_match_score desc

  