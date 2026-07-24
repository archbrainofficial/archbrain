const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Initialize Express App
const app = express();
const PORT = process.env.PORT || 3000;

const path = require('path');

// Middleware
app.use(cors());
app.use(express.json());
// Serve website landing page at root /
app.use(express.static(path.join(__dirname, '../website')));
// Serve admin dashboard at /admin
app.use('/admin', express.static(path.join(__dirname, 'public')));

// Base Route
app.get('/', (req, res) => {
  res.json({
    app: 'ARCHBRAIN Backend API',
    status: 'operational',
    compliance: ['NDPR', 'NITDA', 'NCC'],
    version: '1.0.0'
  });
});

// Import Routes
const authRoutes = require('./routes/auth');
const deviceRoutes = require('./routes/device');
const trackingRoutes = require('./routes/tracking');
const mdmRoutes = require('./routes/mdm');
const consentRoutes = require('./routes/consent');
const adminRoutes = require('./routes/admin');

// Register Routes
app.use('/api/auth', authRoutes);
app.use('/api/device', deviceRoutes);
app.use('/api/tracking', trackingRoutes);
app.use('/api/mdm', mdmRoutes);
app.use('/api/consent', consentRoutes);
// Admin routes (requires admin role)
app.use('/api/admin', adminRoutes);

// Error Handling Middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong on the server.' });
});

// Start Server
app.listen(PORT, () => {
  console.log(`ARCHBRAIN server successfully running on port ${PORT}`);
});
