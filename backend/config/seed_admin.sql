-- Seed an admin user manually using SQL.
-- This requires the password hash to be precomputed. Prefer using the HTTP seed endpoint instead:
-- POST /api/admin/seed-admin with JSON { name, email, phone, password, seed_key }

-- Example manual INSERT (UNHASHED PASSWORD NOT RECOMMENDED):
-- INSERT INTO users (name, email, phone, password_hash, role, subscription_plan)
-- VALUES ('Admin', 'admin@archbrain.local', '0000000000', '<bcrypt-hash-here>', 'admin', 'enterprise');
