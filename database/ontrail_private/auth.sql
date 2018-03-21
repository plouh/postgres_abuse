-- function set_role, responsible for updating role field for tables with
-- row level security enabled
create or replace function ontrail_private.set_role() returns trigger
  language plpgsql
  as $$
begin
  new.role = current_role;
  return new;
end
$$;