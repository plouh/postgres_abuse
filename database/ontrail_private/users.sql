
-- Create table to store users
--
-- email, pass, name, role, verified

-- function check_role_exists to verify that role exists in the database
-- before we allow inserting to users


-- function check_role_on_update to verify that you cannot change role when
-- making updates to users table


-- function encrypt_pass to automatically run a hash for password when
-- inserted to a database

-- Function that is grants permissions to all the tables in our public schema.

-- Signup RPC: function that creates a new user when signing up
--
-- NOTICE: this is in ontrail schema, since it needs to be accessible
-- by postgrest

-- login helper function that tests if email and password matches and
-- returns corresponding role if true

-- jwt_claims is used in postgrest to create JWT token after login.

-- login RPC: function that gets called when logged in
--

-- Grant usage to both schemas for anon account

-- allow anon user to read pg_authid and users -table

-- and finally allow anon account to run login and signup -functions that
-- authenticate users for JWT tokens and create account
