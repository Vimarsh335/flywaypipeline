CREATE TABLE IF NOT EXISTS public.demo2 (
  user_id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  username TEXT NULL,
  email TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);