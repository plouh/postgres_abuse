-- All the sports that are publicly available
create table if not exists ontrail.sport (
  title TEXT PRIMARY KEY not null,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
