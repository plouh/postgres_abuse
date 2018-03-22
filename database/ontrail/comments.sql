-- Table that holds all the comments to the
-- messages

-- create indices on all fields that are used in sort or join clauses
-- namely entry_id, role and created_at
create table if not exists ontrail.comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v1mc(),
  entry_id UUID not null references ontrail.exercise(id),
  user_comment TEXT not null,
  role TEXT REFERENCES ontrail_private.users(role),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE ontrail.comments ENABLE ROW LEVEL SECURITY;

-- only show users own data
drop trigger if exists ensure_role_on_ontrail_comments on ontrail.comments;
create trigger ensure_role_on_ontrail_comments
  before insert on ontrail.comments
  for each row
  execute procedure ontrail_private.set_role();

drop policy if exists ontrail_comments_policy on ontrail.comments;
CREATE POLICY ontrail_comments_policy ON ontrail.comments
  for all
  USING (role = current_user);