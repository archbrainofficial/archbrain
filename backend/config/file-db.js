const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '../data/users.json');
const dataDir = path.join(__dirname, '../data');

// Ensure data directory exists
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

// Initialize users file if it doesn't exist
if (!fs.existsSync(dbPath)) {
  fs.writeFileSync(dbPath, JSON.stringify({ users: [] }, null, 2));
}

function readUsers() {
  try {
    const data = fs.readFileSync(dbPath, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error('Error reading users.json:', err);
    return { users: [] };
  }
}

function writeUsers(data) {
  try {
    fs.writeFileSync(dbPath, JSON.stringify(data, null, 2));
  } catch (err) {
    console.error('Error writing users.json:', err);
  }
}

// Mock pool that mimics pg Pool interface
const fileDb = {
  query: async (text, params) => {
    try {
      const data = readUsers();

      // Handle duplicate email check (SELECT id FROM users WHERE email = $1)
      if (text.includes('SELECT id FROM users WHERE email') && !text.includes('*')) {
        const [email] = params;
        const user = data.users.find(u => u.email === email);
        return { rows: user ? [{ id: user.id }] : [] };
      }

      // Handle user registration INSERT
      if (text.includes('INSERT INTO users') && text.includes('password_hash')) {
        const [name, email, phone, passwordHash] = params;
        const id = `user-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        const user = {
          id,
          name,
          email,
          phone,
          password_hash: passwordHash,
          role: 'user',
          subscription_plan: 'free',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        data.users.push(user);
        writeUsers(data);
        console.log(`✅ User registered: ${email}`);
        return {
          rows: [{ id, name, email, role: 'user', subscription_plan: 'free' }]
        };
      }

      // Handle user lookup for login (SELECT * FROM users WHERE email = $1)
      if (text.includes('SELECT * FROM users WHERE email')) {
        const [email] = params;
        const user = data.users.find(u => u.email === email);
        if (user) {
          console.log(`✅ User found for login: ${email}`);
          return { rows: [user] };
        }
        console.log(`⚠️  User not found: ${email}`);
        return { rows: [] };
      }

      console.warn(`⚠️  Unhandled query: ${text.substring(0, 100)}`);
      return { rows: [] };
    } catch (err) {
      console.error('File DB error:', err);
      return { rows: [] };
    }
  }
};

module.exports = fileDb;

