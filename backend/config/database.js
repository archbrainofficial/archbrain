const { Pool } = require('pg');
require('dotenv').config();

const isProduction = process.env.NODE_ENV === 'production';

// Use file-based database by default for local dev
// Only use PostgreSQL if explicitly configured in production
const shouldUsePostgres = isProduction && process.env.DATABASE_URL;

let pool;

if (shouldUsePostgres) {
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });
  console.log('✅ Using PostgreSQL');
} else {
  // Default to file-based database for development
  console.log('📁 Using file-based database (data/users.json)');
  pool = require('./file-db');
}

module.exports = pool;
