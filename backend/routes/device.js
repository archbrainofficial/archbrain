const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const pool = require('../config/database');

// Register a new device to the user
router.post('/register-device', auth, async (req, res) => {
  const { imei, model, os_version } = req.body;
  const userId = req.user.id;

  if (!imei || !model || !os_version) {
    return res.status(400).json({ error: 'Please provide IMEI, device model, and OS version.' });
  }

  try {
    // Check if IMEI is already registered
    const existing = await pool.query('SELECT id FROM devices WHERE imei = $1', [imei]);
    if (existing.rows && existing.rows.length > 0) {
      return res.status(400).json({ error: 'Device with this IMEI is already registered.' });
    }

    const result = await pool.query(
      'INSERT INTO devices (user_id, imei, model, os_version) VALUES ($1, $2, $3, $4) RETURNING *',
      [userId, imei, model, os_version]
    );

    const device = result.rows[0] || { user_id: userId, imei, model, os_version, status: 'online' };

    // Automatically create empty default policies for the device
    await pool.query('INSERT INTO policies (device_id) VALUES ($1) ON CONFLICT DO NOTHING', [device.id]);

    res.status(201).json({ message: 'Device registered successfully', device });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error registering device.' });
  }
});

// List all devices for the logged-in user
router.get('/list-devices', auth, async (req, res) => {
  const userId = req.user.id;

  try {
    const result = await pool.query('SELECT * FROM devices WHERE user_id = $1', [userId]);
    res.json(result.rows || []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching devices.' });
  }
});

// Remove/unregister device
router.delete('/remove-device/:deviceId', auth, async (req, res) => {
  const userId = req.user.id;
  const { deviceId } = req.params;

  try {
    const check = await pool.query('SELECT id FROM devices WHERE id = $1 AND user_id = $2', [deviceId, userId]);
    if (!check.rows || check.rows.length === 0) {
      return res.status(404).json({ error: 'Device not found or not owned by you.' });
    }

    await pool.query('DELETE FROM devices WHERE id = $1', [deviceId]);
    res.json({ message: 'Device unregistered successfully.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error deleting device.' });
  }
});

// Verify IMEI number and issue verification security code
router.post('/verify-imei', (req, res) => {
  const { imei } = req.body;
  if (!imei) {
    return res.status(400).json({ valid: false, error: 'Incorrect IMEI: IMEI number is required' });
  }

  const cleanImei = String(imei).trim();
  if (cleanImei.length !== 15 || isNaN(cleanImei)) {
    return res.status(400).json({ valid: false, error: 'Incorrect IMEI: Must be exactly 15 digits' });
  }

  // Luhn algorithm checksum verification
  let sum = 0;
  for (let i = 0; i < 15; i++) {
    let digit = parseInt(cleanImei.charAt(i), 10);
    if (i % 2 === 1) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }

  if (sum % 10 !== 0) {
    return res.status(400).json({ valid: false, error: 'Incorrect IMEI: Checksum validation failed' });
  }

  // Generate 6-digit verification security code
  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();

  return res.json({
    valid: true,
    imei: cleanImei,
    verificationCode: verificationCode,
    message: 'IMEI verified successfully! Security code generated.'
  });
});

module.exports = router;
