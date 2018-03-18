create or replace function ontrail.import_user(_user json) returns void
  language sql
as $$
  select ontrail.signup(_user->>'email', text(gen_random_uuid()), _user->>'username')
$$;

create or replace function ontrail.import_sport(_sport json) returns void
  language sql
as $$
  insert into ontrail.sport(title) values (_sport->>'_id')
$$;

create or replace function ontrail.import_exercise(_ex json) returns UUID
  language PLPGSQL
  as $$
declare
  _role name;
  _comment json;
  _entryId UUID;
  _res UUID;
begin
  select role from ontrail_private.users where name = _ex->>'user' into _role;

  execute format('set role %I', _role);
  insert into ontrail.exercise (title, description, sport, avg_hr, distance, duration, created_at)
    values (
      _ex->>'title',
      _ex->>'body',
      _ex->>'sport',
      (_ex->'avghr'->>'$numberLong')::float,
      (_ex->'distance'->>'$numberLong')::float,
      (_ex->'duration'->>'$numberLong')::float,
      (_ex->'creationDate'->>'$date')::timestamptz
    ) returning id into _entryId;
  execute 'set role postgres';

  for _comment in select * from json_array_elements((_ex->>'comments')::json)
  loop
    select role from ontrail_private.users where name = _comment->>'user' into _role;

    if _role is not null then
      execute format('set role %I', _role);
      insert into ontrail.comments(entry_id, user_comment, created_at)
        values (
          _entryId,
          _comment->'body',
          to_timestamp(_comment->>'date', 'DD.MM.YYYY HH24:MI')
        );
    end if;
    execute 'set role postgres';
  end loop;

  return _entryId;
end;
$$;
