-- create table that contains exercise details
-- title, description, sport (reference to global sports), duration, avg_hr, distance
--
-- some fields are left out in purpose: distance, repeats, volume(kg), elevation
create table if not exists ontrail.exercise (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v1mc(),
  title TEXT not null,
  description text not null default '',
  sport text not null references ontrail.sport(title),
  duration int,
  distance float,
  avg_hr int,
  role TEXT REFERENCES ontrail_private.users(role),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE ontrail.exercise ENABLE ROW LEVEL SECURITY;

-- only show users own data
drop trigger if exists ensure_role_on_ontrail_exercise on ontrail.exercise;
create trigger ensure_role_on_ontrail_exercise
  before insert on ontrail.exercise
  for each row
  execute procedure ontrail_private.set_role();

drop policy if exists ontrail_exercise_policy on ontrail.exercise;
CREATE POLICY ontrail_exercise_policy ON ontrail.exercise
  for all
  USING (role = current_user);


-- create indices on all fields that are used in sort or join clauses
-- namely role, sport and created_at
create index if not exists ontrail_exercise_role_index on ontrail.exercise(role);
create index if not exists ontrail_exercise_sport_index on ontrail.exercise(sport);
create index if not exists ontrail_exercise_created_at_index on ontrail.exercise(created_at);
