
-- Create table to store users
--
-- email, pass, name, role, verified
create table if not exists ontrail_private.users (
  email    text primary key check ( email ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512 and length(pass) > 30),
  name     text not null default '',
  role     name not null check (length(role) < 512) unique,
  verified boolean not null default false

);
-- function check_role_exists to verify that role exists in the database
-- before we allow inserting to users
create or replace function ontrail_private.check_role_exists() returns trigger
  language plpgsql
  as $$
begin
  if not exists (select 1 from pg_roles r where r.rolname = new.role) THEN
    raise foreign_key_violation using message = 'User role is does not exist ' || new.role;
  end if;
  return new;
end
$$;

drop trigger if exists trigger_check_role_exists on ontrail_private.users;
create constraint trigger trigger_check_role_exists
  after insert or update on ontrail_private.users
  for each row
  execute procedure ontrail_private.check_role_exists();

-- function check_role_on_update to verify that you cannot change role when
-- making updates to users table
create or replace function ontrail_private.check_role_on_update() returns trigger
  language plpgsql
  as $$
begin
  if new.role <> old.role then
    raise foreign_key_violation using message = 'Cannot update role ' || old.role || ' to ' || new.role;
  end if;
  return new;
end
$$;

drop trigger if exists trigger_check_role_on_update on ontrail_private.users;
create constraint trigger trigger_check_role_on_update
  after update on ontrail_private.users
  for each row
  execute procedure ontrail_private.check_role_on_update();

-- function encrypt_pass to automatically run a hash for password when
-- inserted to a database
create or replace function ontrail_private.encrypt_pass() returns trigger
  language plpgsql
  as $$
begin
  if tg_op = 'INSERT' or new.pass <> old.pass then
    new.pass = crypt(new.pass, gen_salt('bf'));
  end if;
  return new;
end
$$;

drop trigger if exists trigger_encrypt_pass on ontrail_private.users;
create trigger trigger_encrypt_pass
  before insert or update on ontrail_private.users
  for each row
  execute procedure ontrail_private.encrypt_pass();

-- Function that is grants permissions to all the tables in our public schema.
create or replace function ontrail_private.grant_permissions(role name) returns void
  language plpgsql
  as $$
begin
  EXECUTE 'grant usage on schema ontrail to ' || quote_ident(role);
  execute 'grant select,insert,update,delete on table ontrail.exercise, ontrail.comments to ' || quote_ident(role);
  EXECUTE 'grant select on TABLE ontrail.sport, ontrail.feed to ' || quote_ident(role);
end
$$;
-- Signup RPC: function that creates a new user when signing up
--
-- NOTICE: this is in ontrail schema, since it needs to be accessible
-- by postgrest
create or replace function ontrail.signup(email text, pass text, name text) returns void
  language plpgsql
  security definer
  as $$
DECLARE
  _role text;
begin
  select replace(text(gen_random_uuid()), '-', '') into _role;

  execute 'create role ' || quote_ident(_role) || ' nologin';
  perform ontrail_private.grant_permissions(_role);
  execute 'grant ' || quote_ident(_role) || ' to ontrail_authenticator';

  insert into ontrail_private.users(email, pass, name, role)
    values (signup.email, signup.pass, signup.name, _role);
end
$$;

-- login helper function that tests if email and password matches and
-- returns corresponding role if true
create or replace function ontrail_private.check_role(email text, pass text) returns name
  language plpgsql
  as $$
begin
  return (
    select role from ontrail_private.users u
      WHERE u.email = check_role.email AND
        u.pass = crypt(check_role.pass, u.pass)
  );
end
$$;

-- jwt_claims is used in postgrest to create JWT token after login.
drop type if exists ontrail_private.jwt_claims cascade;
create type ontrail_private.jwt_claims AS (email text, role name, exp double precision);

-- login RPC: function that gets called when logged in
--
create or replace function ontrail.login(email text, pass text) returns text
  language plpgsql
  as $$
declare
  _role name;
  _token ontrail_private.jwt_claims;
begin
  select ontrail_private.check_role(email, pass) into _role;

  if _role is null then
    raise invalid_password using message = 'Invalid username or password';
    return null;
  end if;

  select login.email as email, _role as role, extract(epoch from now()) + 5 * 6000 as exp into _token;

  return (
    select sign(row_to_json(_token), current_setting('app.jwt_secret'))
  );end
$$;

grant usage on schema ontrail, ontrail_private to ontrail_anon;

-- allow anon user to read pg_authid and users -table
grant select on table pg_authid, ontrail_private.users to ontrail_anon;

-- and finally allow anon account to run login and signup -functions that
-- authenticate users for JWT tokens and create account
grant execute on function ontrail.signup, ontrail.login to ontrail_anon;