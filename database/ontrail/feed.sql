-- create feed that displays all the entries
--
-- include users displaynames and comments as array
create or replace view ontrail.feed as
  select e.id, e.title, e.description, e.sport, e.avg_hr, e.duration, e.distance, e.created_at "date", u.name as username,
  (
    select array_to_json(array_agg(row_to_json(all_comments)))
    from (
      select user_comment, u2.name
        from ontrail.comments c, ontrail_private.users u2
        where u2.role = c.role and c.entry_id = e.id
        order by c.created_at asc
    ) all_comments
  ) as comments

  from ontrail.exercise e, ontrail_private.users u
  where e.role = u.role
  order by e.created_at desc;