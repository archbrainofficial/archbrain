document.addEventListener('DOMContentLoaded', () => {
  
  // 1. Initialize Leaflet Map centered around Lagos, Nigeria
  const map = L.map('leaflet-admin-map', {
    zoomControl: false, // Keep it clean
    attributionControl: false
  }).setView([6.4950, 3.4000], 11); // Balanced center for Ikeja, Lekki, VI, and Oshodi

  // CartoDB Dark Matter layer
  L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
    maxZoom: 19
  }).addTo(map);

  // 2. Define coordinates and labels matching the image pins
  const pinData = [
    { label: "Lekki - 15 devices", coords: [6.4311, 3.4658] },
    { label: "Ikeja - 12 devices", coords: [6.5960, 3.3400] },
    { label: "Oshodi - 9 devices", coords: [6.5358, 3.3361] },
    { label: "VI - 8 devices", coords: [6.4281, 3.4219] }
  ];

  // Helper to build the custom divIcon matching the image's pink pin + black label
  function createCustomIcon(labelText) {
    return L.divIcon({
      className: 'custom-leaflet-pin',
      html: `
        <div class="pin-wrapper">
          <span class="pin-label">${labelText}</span>
          <div class="pin-dot"></div>
        </div>
      `,
      iconSize: [120, 50],
      iconAnchor: [60, 42]
    });
  }

  // Draw markers on map
  const markers = {};
  pinData.forEach(pin => {
    const key = pin.label.split(' - ')[0].toLowerCase(); // 'lekki', 'ikeja', etc.
    const marker = L.marker(pin.coords, {
      icon: createCustomIcon(pin.label)
    }).addTo(map);
    markers[key] = marker;
  });

  // Coordinates matching the specific device rows
  const deviceLocations = {
    '1': { coords: [6.5960, 3.3400], name: "Chukwu's Phone", place: "Ikeja Market" },
    '2': { coords: [6.4281, 3.4219], name: "Amina's Phone", place: "Victoria Island" },
    '3': { coords: [6.4311, 3.4658], name: "Tunde's Phone", place: "Lekki Phase 1" },
    '4': { coords: [6.5358, 3.3361], name: "Device #4", place: "Oshodi" }
  };

  // 3. Define Table Actions

  window.handleLock = function(deviceId) {
    const dev = deviceLocations[deviceId];
    if (!dev) return;

    const pin = prompt(`Enter 6-digit recovery lock PIN for ${dev.name}:`);
    if (!pin) return;

    if (pin.length !== 6 || isNaN(pin)) {
      alert("Error: PIN must be exactly 6 digits.");
      return;
    }

    alert(`Lock command successfully enqueued for ${dev.name}.\nPIN ${pin} will be enforced.`);
    
    // Visually update state
    const row = document.querySelector(`tr[data-id="${deviceId}"]`);
    if (row) {
      const statusCell = row.querySelector('.status-indicator');
      statusCell.className = "status-indicator status-warning";
      statusCell.innerHTML = `<span class="status-dot"></span><span>Locked</span>`;
    }
  };

  window.handleFind = function(deviceId) {
    const dev = deviceLocations[deviceId];
    if (!dev) return;

    // Pan map directly to device region coordinates and open popup
    map.setView(dev.coords, 14, { animate: true, duration: 1.0 });
    
    // Find the corresponding marker key
    let markerKey = '';
    if (dev.place.includes("Ikeja")) markerKey = 'ikeja';
    else if (dev.place.includes("Victoria")) markerKey = 'vi';
    else if (dev.place.includes("Lekki")) markerKey = 'lekki';
    else if (dev.place.includes("Oshodi")) markerKey = 'oshodi';

    if (markerKey && markers[markerKey]) {
      // Glow/bounce animation
      const element = markers[markerKey].getElement();
      if (element) {
        element.style.transform = `${element.style.transform} scale(1.2)`;
        setTimeout(() => {
          element.style.transform = element.style.transform.replace(' scale(1.2)', '');
        }, 800);
      }
    }
  };

  window.handleWipe = function(deviceId) {
    const dev = deviceLocations[deviceId];
    if (!dev) return;

    const confirmWipe = confirm(`CRITICAL WARNING:\nAre you sure you want to trigger a remote factory wipe on ${dev.name}?\nAll databases, vaults, and customer records will be permanently erased. THIS IS IRREVERSIBLE.`);
    if (!confirmWipe) return;

    alert(`Remote Wipe authorization signature sent. Erasing ${dev.name}...`);
    
    // Visually wipe state
    const row = document.querySelector(`tr[data-id="${deviceId}"]`);
    if (row) {
      const statusCell = row.querySelector('.status-indicator');
      statusCell.className = "status-indicator status-offline";
      statusCell.innerHTML = `<span class="status-dot"></span><span>Wiped / Offline</span>`;
      
      const batteryCell = row.querySelector('.battery-text');
      batteryCell.className = "battery-text text-muted";
      batteryCell.textContent = "--";

      // Disable buttons
      const buttons = row.querySelectorAll('.btn-action');
      buttons.forEach(btn => {
        btn.disabled = true;
        btn.style.opacity = '0.3';
        btn.style.cursor = 'not-allowed';
      });
    }
  };

  // Top level headers buttons alert
  document.getElementById('btn-enroll').addEventListener('click', () => {
    alert("Opening enrollment modal...\nConfigure device specifications and IMEI codes.");
  });

  document.getElementById('btn-reports').addEventListener('click', () => {
    alert("Generating compliance and lock analytics report...");
  });

});
