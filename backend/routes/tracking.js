const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const pool = require('../config/database');

// Update device location (called by the app client)
router.post('/update-location', auth, async (req, res) => {
  const { device_id, latitude, longitude, speed, battery_level } = req.body;
  if (!device_id || latitude === undefined || longitude === undefined) {
    return res.status(400).json({ error: 'Missing required location parameters.' });
  }

  try {
    // Verify user owns device
    const deviceCheck = await pool.query('SELECT id FROM devices WHERE id = $1 AND user_id = $2', [device_id, req.user.id]);
    if (!deviceCheck.rows || deviceCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Forbidden. You do not own this device.' });
    }

    // Insert tracking point
    await pool.query(
      'INSERT INTO tracking_history (device_id, latitude, longitude, speed) VALUES ($1, $2, $3, $4)',
      [device_id, latitude, longitude, speed || 0.0]
    );

    // Update battery level and updated timestamp
    await pool.query(
      'UPDATE devices SET battery_level = $1, status = $2, updated_at = NOW() WHERE id = $3',
      [battery_level || 100, 'online', device_id]
    );

    res.json({ message: 'Location updated successfully.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error recording tracking coordinates.' });
  }
});

// Fetch location history for a device
router.get('/history/:deviceId', auth, async (req, res) => {
  const { deviceId } = req.params;
  const userId = req.user.id;

  try {
    // Verify device ownership
    const check = await pool.query(
      'SELECT d.id, u.subscription_plan FROM devices d JOIN users u ON d.user_id = u.id WHERE d.id = $1 AND d.user_id = $2',
      [deviceId, userId]
    );
    if (!check.rows || check.rows.length === 0) {
      return res.status(403).json({ error: 'Forbidden. Device not owned by you.' });
    }

    const plan = check.rows[0].subscription_plan;
    
    // Free plans get 7 days, Premium/Business plans get 90 days of tracking logs
    const limitDays = plan === 'free' ? 7 : 90;

    const result = await pool.query(
      `SELECT latitude, longitude, speed, recorded_at 
       FROM tracking_history 
       WHERE device_id = $1 AND recorded_at > NOW() - INTERVAL '$2 days'
       ORDER BY recorded_at DESC`,
      [deviceId, limitDays]
    );

    res.json({
      plan,
      retention_days: limitDays,
      history: result.rows || []
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching location history.' });
  }
});

module.exports = router;
