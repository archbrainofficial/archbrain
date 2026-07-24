const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const pool = require('../config/database');

// Enqueue a lock or wipe command (Admin or Device Owner dashboard)
router.post('/enqueue-command', auth, async (req, res) => {
  const { device_id, command_type, payload } = req.body;
  if (!device_id || !command_type) {
    return res.status(400).json({ error: 'Missing device_id or command_type.' });
  }

  try {
    // Check ownership and subscription plan limits
    const check = await pool.query(
      `SELECT d.id, u.subscription_plan 
       FROM devices d 
       JOIN users u ON d.user_id = u.id 
       WHERE d.id = $1 AND d.user_id = $2`,
      [device_id, req.user.id]
    );

    if (!check.rows || check.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied. You do not own this device.' });
    }

    const plan = check.rows[0].subscription_plan;
    if (plan === 'free' && (command_type === 'wipe' || command_type === 'lock')) {
      return res.status(403).json({ 
        error: `Remote ${command_type} requires a Premium subscription plan.`, 
        requires_upgrade: true 
      });
    }

    // Insert command in pending state
    const result = await pool.query(
      `INSERT INTO mdm_commands (device_id, command_type, payload, status, admin_id) 
       VALUES ($1, $2, $3, 'pending', $4) RETURNING *`,
      [device_id, command_type, payload ? JSON.stringify(payload) : null, req.user.id]
    );

    res.status(201).json({ message: 'MDM command enqueued successfully', command: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error queuing command.' });
  }
});

// Device fetches pending commands (polling endpoint)
router.get('/pending-commands/:deviceId', auth, async (req, res) => {
  const { deviceId } = req.params;

  try {
    const result = await pool.query(
      `SELECT * FROM mdm_commands 
       WHERE device_id = $1 AND status = 'pending' 
       ORDER BY created_at ASC`,
      [deviceId]
    );

    // Update command status to 'sent'
    if (result.rows && result.rows.length > 0) {
      const ids = result.rows.map(row => row.id);
      await pool.query('UPDATE mdm_commands SET status = $1, updated_at = NOW() WHERE id = ANY($2)', ['sent', ids]);
    }

    res.json(result.rows || []);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error fetching pending commands.' });
  }
});

// Acknowledge command execution
router.post('/acknowledge-command', auth, async (req, res) => {
  const { command_id, status } = req.body; // status should be 'executed' or 'failed'
  if (!command_id || !status) {
    return res.status(400).json({ error: 'Missing command_id or status.' });
  }

  try {
    await pool.query(
      'UPDATE mdm_commands SET status = $1, updated_at = NOW() WHERE id = $2',
      [status, command_id]
    );
    res.json({ message: 'Command acknowledgment recorded.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error updating command status.' });
  }
});

// Update security policy configuration (Business plan feature)
router.post('/update-policies/:deviceId', auth, async (req, res) => {
  const { deviceId } = req.params;
  const { block_whatsapp, block_games, pin_required, location_mandatory } = req.body;

  try {
    // Verify business/admin rights
    const check = await pool.query(
      `SELECT d.id, u.subscription_plan 
       FROM devices d 
       JOIN users u ON d.user_id = u.id 
       WHERE d.id = $1 AND d.user_id = $2`,
      [deviceId, req.user.id]
    );

    if (!check.rows || check.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    const plan = check.rows[0].subscription_plan;
    if (plan !== 'business' && plan !== 'enterprise') {
      return res.status(403).json({ error: 'Security policy settings require a Business/Enterprise plan.' });
    }

    const result = await pool.query(
      `INSERT INTO policies (device_id, block_whatsapp, block_games, pin_required, location_mandatory, updated_at)
       VALUES ($1, $2, $3, $4, $5, NOW())
       ON CONFLICT (device_id) DO UPDATE SET 
         block_whatsapp = EXCLUDED.block_whatsapp,
         block_games = EXCLUDED.block_games,
         pin_required = EXCLUDED.pin_required,
         location_mandatory = EXCLUDED.location_mandatory,
         updated_at = NOW()
       RETURNING *`,
      [deviceId, !!block_whatsapp, !!block_games, !!pin_required, !!location_mandatory]
    );

    res.json({ message: 'MDM policies updated successfully', policies: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error updating policies.' });
  }
});

module.exports = router;
