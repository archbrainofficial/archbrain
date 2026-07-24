const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const isAdmin = require('../middleware/isAdmin');

// Seed an admin user (protected by ADMIN_SEED_KEY env var)
router.post('/seed-admin', async (req, res) => {
  const { name, email, phone, password, seed_key } = req.body;
  if (!process.env.ADMIN_SEED_KEY) {
    return res.status(500).json({ error: 'ADMIN_SEED_KEY not configured on server.' });
  }
  if (seed_key !== process.env.ADMIN_SEED_KEY) {
    return res.status(403).json({ error: 'Invalid seed key.' });
  }
  if (!name || !email || !phone || !password) {
    return res.status(400).json({ error: 'Missing required fields.' });
  }

  try {
    const check = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (check.rows && check.rows.length > 0) {
      return res.status(400).json({ error: 'User with this email already exists.' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const result = await pool.query(
      'INSERT INTO users (name, email, phone, password_hash, role, subscription_plan) VALUES ($1,$2,$3,$4,$5,$6) RETURNING id, name, email, role',
      [name, email, phone, passwordHash, 'admin', 'enterprise']
    );

    res.status(201).json({ message: 'Admin user created.', user: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// List users
router.get('/users', auth, isAdmin, async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name, email, phone, role, subscription_plan, created_at FROM users ORDER BY created_at DESC LIMIT 500');
    res.json(result.rows || []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching users.' });
  }
});

// List devices with owner info
router.get('/devices', auth, isAdmin, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT d.id, d.imei, d.model, d.os_version, d.battery_level, d.status, d.created_at, u.id AS owner_id, u.name AS owner_name, u.email AS owner_email
       FROM devices d JOIN users u ON d.user_id = u.id ORDER BY d.created_at DESC LIMIT 1000`
    );
    res.json(result.rows || []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching devices.' });
  }
});

// List MDM commands
router.get('/commands', auth, isAdmin, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM mdm_commands ORDER BY created_at DESC LIMIT 1000');
    res.json(result.rows || []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching commands.' });
  }
});

// List consent records
router.get('/consents', auth, isAdmin, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM consent_records ORDER BY consented_at DESC LIMIT 1000');
    res.json(result.rows || []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching consents.' });
  }
});

// Force a wipe command for a device
router.post('/device/:deviceId/force-wipe', auth, isAdmin, async (req, res) => {
  const { deviceId } = req.params;
  try {
    const result = await pool.query(
      `INSERT INTO mdm_commands (device_id, command_type, payload, status, admin_id) VALUES ($1,$2,$3,'pending',$4) RETURNING *`,
      [deviceId, 'wipe', null, req.user.id]
    );
    res.status(201).json({ message: 'Wipe command enqueued.', command: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error enqueuing wipe.' });
  }
});

// Force a lock command for a device
router.post('/device/:deviceId/force-lock', auth, isAdmin, async (req, res) => {
  const { deviceId } = req.params;
  const { pin } = req.body;
  try {
    const payload = pin ? { pin } : null;
    const result = await pool.query(
      `INSERT INTO mdm_commands (device_id, command_type, payload, status, admin_id) VALUES ($1,$2,$3,'pending',$4) RETURNING *`,
      [deviceId, 'lock', payload ? JSON.stringify(payload) : null, req.user.id]
    );
    res.status(201).json({ message: 'Lock command enqueued.', command: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error enqueuing lock.' });
  }
});

module.exports = router;
