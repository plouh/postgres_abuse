-- pgcrypto extension for password hash and JWT creation
create extension if not exists pgcrypto;

-- uuid-ossp is used to give database tables random UUID's
-- instead of incremental ones
create extension if not exists "uuid-ossp";

-- pgjwt is needed for signing the authentication tokens
create extension if not exists pgjwt;

-- mandatory roles and their relationships for postgrest
create role ontrail_anon;
create role ontrail_authenticator noinherit createrole;
grant ontrail_anon to ontrail_authenticator;

-- create public schemas here
create schema if not exists ontrail;

-- create private schemas here
create schema if not exists ontrail_private;