const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const pool = require('../config/database');

// Record compliance consent (opt-in)
router.post('/record-consent', auth, async (req, res) => {
  const { device_id, consent_given } = req.body;
  const userId = req.user.id;
  const ipAddress = req.ip || req.headers['x-forwarded-for'] || req.socket.remoteAddress;

  if (!device_id || consent_given === undefined) {
    return res.status(400).json({ error: 'Missing device_id or consent_given.' });
  }

  try {
    // Check if device belongs to user
    const check = await pool.query('SELECT id FROM devices WHERE id = $1 AND user_id = $2', [device_id, userId]);
    if (!check.rows || check.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied. Device ownership verification failed.' });
    }

    if (consent_given) {
      // Add or update active consent
      const result = await pool.query(
        `INSERT INTO consent_records (user_id, device_id, ip_address, consent_given, consented_at)
         VALUES ($1, $2, $3, TRUE, NOW())
         RETURNING *`,
        [userId, device_id, ipAddress]
      );
      res.status(201).json({ message: 'Consent registered successfully under NDPR policy.', record: result.rows[0] });
    } else {
      // Mark consent as withdrawn
      await pool.query(
        `UPDATE consent_records 
         SET consent_given = FALSE, withdrawn_at = NOW() 
         WHERE user_id = $1 AND device_id = $2 AND consent_given = TRUE`,
        [userId, device_id]
      );
      res.json({ message: 'Consent successfully withdrawn.' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error recording consent logs.' });
  }
});

// Verify consent status
router.get('/verify-consent/:deviceId', auth, async (req, res) => {
  const { deviceId } = req.params;
  const userId = req.user.id;

  try {
    const result = await pool.query(
      `SELECT consent_given, consented_at, withdrawn_at 
       FROM consent_records 
       WHERE user_id = $1 AND device_id = $2
       ORDER BY consented_at DESC LIMIT 1`,
      [userId, deviceId]
    );

    const hasConsent = result.rows && result.rows.length > 0 && result.rows[0].consent_given;
    res.json({
      device_id: deviceId,
      consent_active: hasConsent,
      details: result.rows[0] || null
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error verifying consent records.' });
  }
});

module.exports = router;
