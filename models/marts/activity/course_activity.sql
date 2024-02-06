{{
    config(
        unique_key='id',
        on_schema_change='fail' -- DJ 2024/02/06 we could choose a different option here obvs
    )
}}

select
	id,
	_synced_at,
	created_at,
	previous_id,
	user_id,
  type,
	params,
from {{ ref('stg_s_learntracking__user_activity') }}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- uses > to include records which were synced since the last run of this model
  -- applies a negative tolerance to handle sync variance
  -- future idea - use knowledge of the schedule to avoid full scan to get max(synced)??
  where _synced_at > (select max( {{ dateadd("minute", -{{ var("timestamp_tolerance_mins") }}, _synched_at) }} ) from {{ this }}

{% endif %}
