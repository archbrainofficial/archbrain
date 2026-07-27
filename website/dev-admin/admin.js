function authHeaders() {
  const token = document.getElementById('token').value.trim();
  return token ? { 'Authorization': token, 'Content-Type': 'application/json' } : { 'Content-Type': 'application/json' };
}

async function fetchJson(path, opts) {
  const res = await fetch(path, opts);
  const text = await res.text();
  try { return JSON.parse(text); } catch(e) { return text; }
}

async function loadUsers(){
  const h = authHeaders();
  const data = await fetchJson('/api/admin/users', { headers: h });
  document.getElementById('users').textContent = JSON.stringify(data, null, 2);
}

async function loadDevices(){
  const h = authHeaders();
  const data = await fetchJson('/api/admin/devices', { headers: h });
  document.getElementById('devices').textContent = JSON.stringify(data, null, 2);
}

async function loadCommands(){
  const h = authHeaders();
  const data = await fetchJson('/api/admin/commands', { headers: h });
  document.getElementById('commands').textContent = JSON.stringify(data, null, 2);
}

async function loadConsents(){
  const h = authHeaders();
  const data = await fetchJson('/api/admin/consents', { headers: h });
  document.getElementById('consents').textContent = JSON.stringify(data, null, 2);
}

document.getElementById('refresh').addEventListener('click', () => {
  loadUsers(); loadDevices(); loadCommands(); loadConsents();
});

document.getElementById('seed_btn').addEventListener('click', async () => {
  const name = document.getElementById('seed_name').value;
  const email = document.getElementById('seed_email').value;
  const phone = document.getElementById('seed_phone').value;
  const password = document.getElementById('seed_password').value;
  const seed_key = document.getElementById('seed_key').value;
  const res = await fetch('/api/admin/seed-admin', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name, email, phone, password, seed_key })
  });
  const data = await res.json();
  document.getElementById('seed_result').textContent = JSON.stringify(data, null, 2);
});

// Auto-refresh once on load
loadUsers(); loadDevices(); loadCommands(); loadConsents();
