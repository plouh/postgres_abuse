-- create feed that displays all the entries
--
-- include users displaynames and comments as array
create view ontrail.feed AS
 select e.id, title, description, sport, duration, distance, avg_hr, u.name as username,
 (
   select array_to_json(array_agg(row_to_json(all_comments))) from (
     select user_comment, u2.role as username
       from ontrail.comments c, ontrail_private.users u2
       where c.role = u2.role and c.entry_id = e.id
       order by c.created_at asc
   ) all_comments
 ) as comments
 from ontrail.exercise e, ontrail_private.users u
 where e.role = u.role
 order by e.created_at desc;