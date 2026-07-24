const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretjwtkeyforarchbrainsecurity';

// User registration
router.post('/register', async (req, res) => {
  const { name, email, phone, password } = req.body;
  if (!name || !email || !phone || !password) {
    return res.status(400).json({ error: 'Please provide all required fields.' });
  }

  try {
    // Check if user already exists
    const checkUser = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (checkUser.rows && checkUser.rows.length > 0) {
      return res.status(400).json({ error: 'User with this email already exists.' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Insert user
    const newUser = await pool.query(
      'INSERT INTO users (name, email, phone, password_hash) VALUES ($1, $2, $3, $4) RETURNING id, name, email, role, subscription_plan',
      [name, email, phone, passwordHash]
    );

    if (!newUser.rows || newUser.rows.length === 0) {
      console.error('Registration failed: No user returned from database insert.');
      return res.status(500).json({ error: 'Database error: User creation failed. Please check your database connection.' });
    }

    const user = newUser.rows[0];

    // Generate JWT
    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({ token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error during registration.' });
  }
});

// User login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Please provide email and password.' });
  }

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (!result.rows || result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid email or password.' });
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password.' });
    }

    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        subscription_plan: user.subscription_plan
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error during login.' });
  }
});

module.exports = router;
