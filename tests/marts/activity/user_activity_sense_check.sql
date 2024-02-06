-- DJ 2024/02/06 Consider creating the user summary as a separate (useful?) model
with user_course_summary as (
    select
      user_id,
      json_type(params.course_key) as course_key,
      sum(case when type = 'course_started' then 1 else 0 end) as course_starts,
      max(case when type = 'course_started' then created_at else null end) as max_course_start,
      sum(case when type = 'course_completed' then 1 else 0 end) as course_ends,
      max(case when type = 'course_completed' then created_at else null end) as max_course_end,
    from {{ ref('course_activity') }}
    group by 1, 2
)
select *
from user_course_summary
where
    course_starts > 1
    or course_ends > 1
    or (max_course_end is not null and max_course_end < max_course_start)