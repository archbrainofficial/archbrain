document.addEventListener('DOMContentLoaded', () => {
  
  // 1. Initialize Leaflet Map centered around Lagos, Nigeria
  const lagosCoords = [6.5244, 3.3792];
  const map = L.map('leaflet-map', {
    zoomControl: true,
    attributionControl: false
  }).setView(lagosCoords, 11);

  // CartoDB Dark Matter tile layer for premium dark appearance
  L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
    maxZoom: 19
  }).addTo(map);

  // Define Mock Device Coordinates
  const deviceData = {
    s24: {
      name: "Amina's Galaxy S24",
      coords: [6.4281, 3.4219], // Victoria Island
      locationName: "Victoria Island, Lagos",
      battery: "82%",
      os: "Android 14 (One UI 6.1)",
      status: "online"
    },
    pixel8: {
      name: "Chukwu's Pixel 8 Pro",
      coords: [6.5960, 3.3400], // Ikeja
      locationName: "Ikeja, Lagos",
      battery: "95%",
      os: "Android 14 (Vanilla OS)",
      status: "online"
    },
    iphone15: {
      name: "Tunde's iPhone 15",
      coords: [6.4311, 3.4658], // Lekki Phase 1
      locationName: "Lekki Phase 1, Lagos",
      battery: "55%",
      os: "iOS 17.5",
      status: "online"
    }
  };

  // Keep track of markers
  const markers = {};
  let activeDeviceId = 's24';

  // Add markers to map
  Object.keys(deviceData).forEach(id => {
    const dev = deviceData[id];
    const marker = L.marker(dev.coords).addTo(map);
    marker.bindPopup(`<b>${dev.name}</b><br>${dev.locationName}`);
    markers[id] = marker;
  });

  // Center map on Amina's device initially
  map.setView(deviceData.s24.coords, 13);

  // 2. Handle Device List Selection
  const deviceItems = document.querySelectorAll('.device-item');
  deviceItems.forEach(item => {
    item.addEventListener('click', () => {
      // Toggle active UI state
      deviceItems.forEach(el => el.classList.remove('active'));
      item.classList.add('active');

      const id = item.getAttribute('data-device');
      activeDeviceId = id;

      const device = deviceData[id];
      if (device.status === 'wiped') {
        logConsole(`[SYSTEM]: Device ${device.name} is wiped. Coordinates unavailable.`, 'error');
        return;
      }

      // Pan map
      map.setView(device.coords, 13);
      markers[id].openPopup();

      logConsole(`[DEVICE]: Switched active console to ${device.name}`);
    });
  });

  // Helper: Write to virtual console log
  const consoleLines = document.getElementById('console-lines');
  function logConsole(message, type = 'info') {
    const div = document.createElement('div');
    const timestamp = new Date().toLocaleTimeString();
    
    if (type === 'error') {
      div.style.color = '#f87171';
    } else if (type === 'success') {
      div.style.color = '#10b981';
    } else {
      div.style.color = '#38bdf8';
    }
    
    div.textContent = `[${timestamp}] ${message}`;
    consoleLines.appendChild(div);
    consoleLines.scrollTop = consoleLines.scrollHeight;
  }

  // 3. Control Panel Diagnostic Actions
  
  // Locate Device
  document.getElementById('action-locate').addEventListener('click', () => {
    const device = deviceData[activeDeviceId];
    if (device.status === 'wiped') {
      alert("This device has been wiped. It is no longer reachable.");
      return;
    }
    
    logConsole(`[COMMAND]: Requesting secure GPS coordinates for ${device.name}...`);
    
    setTimeout(() => {
      map.setView(device.coords, 14);
      markers[activeDeviceId].openPopup();
      
      // Simulate slight location variance to prove "real-time updates"
      const latOffset = (Math.random() - 0.5) * 0.001;
      const lngOffset = (Math.random() - 0.5) * 0.001;
      device.coords[0] += latOffset;
      device.coords[1] += lngOffset;
      markers[activeDeviceId].setLatLng(device.coords);
      
      logConsole(`[SUCCESS]: ${device.name} localized at [${device.coords[0].toFixed(6)}, ${device.coords[1].toFixed(6)}]`, 'success');
    }, 800);
  });

  // Send Alert
  document.getElementById('action-alert').addEventListener('click', () => {
    const device = deviceData[activeDeviceId];
    if (device.status === 'wiped') return;
    
    logConsole(`[COMMAND]: Transmitting audible alert request to ${device.name}...`);
    setTimeout(() => {
      logConsole(`[SUCCESS]: Alert command acknowledged. Device buzzer active.`, 'success');
      alert(`Buzzer Command sent to ${device.name}!`);
    }, 600);
  });

  // Remote Lock Device
  document.getElementById('action-lock').addEventListener('click', () => {
    const device = deviceData[activeDeviceId];
    if (device.status === 'wiped') return;
    
    const pin = prompt("Enter a 6-digit recovery lock PIN to push to the device:");
    if (!pin) {
      logConsole("[CANCELLED]: Remote lock aborted by administrator.");
      return;
    }
    
    if (pin.length !== 6 || isNaN(pin)) {
      alert("Error: PIN must be exactly 6 numeric digits.");
      return;
    }

    logConsole(`[COMMAND]: Enqueuing lock payload for ${device.name}...`);
    logConsole(`[PAYLOAD]: Enforcing screen PIN: ******`);
    
    setTimeout(() => {
      device.status = 'locked';
      logConsole(`[SUCCESS]: Screen locked on ${device.name}. Owner contact message displayed.`, 'success');
      
      // Update visual phone mockup to show mock lock screen
      const screenContent = document.querySelector('.screen-content');
      screenContent.innerHTML = `
        <i class="fa-solid fa-lock-open" style="font-size: 64px; color: #f87171; margin-bottom: 20px;"></i>
        <h3 style="color: #f87171;">DEVICE LOCKED</h3>
        <p>This phone belongs to Amina and is reported missing.<br>Contact owner at +234-XXX-XXXX.</p>
        <button id="reset-mock-phone" style="background:var(--accent-cyan); color:#000; padding:8px 16px; border:none; border-radius:4px; font-weight:600; cursor:pointer;">Reset Demo Screen</button>
      `;

      // Bind reset trigger inside simulator mockup
      document.getElementById('reset-mock-phone').addEventListener('click', () => {
        resetMockPhoneVisual();
      });
    }, 1000);
  });

  // Remote Wipe Device
  document.getElementById('action-wipe').addEventListener('click', () => {
    const device = deviceData[activeDeviceId];
    if (device.status === 'wiped') return;

    const confirmWipe = confirm(`WARNING: Initiating remote wipe on ${device.name} will permanently delete ALL data, apps, and configuration. THIS CANNOT BE UNDONE. Proceed?`);
    if (!confirmWipe) {
      logConsole("[CANCELLED]: Remote wipe instruction canceled.");
      return;
    }

    logConsole(`[WARNING]: PUSHING WIPE PROTOCOL TO ${device.name.toUpperCase()}...`, 'error');
    logConsole(`[SYSTEM]: Sending secure authorization signature...`);
    
    setTimeout(() => {
      // Wiping animation log
      logConsole(`[WIPING]: Deleting app cache storage...`);
    }, 600);

    setTimeout(() => {
      logConsole(`[WIPING]: Purging system directory schemas...`);
    }, 1200);

    setTimeout(() => {
      device.status = 'wiped';
      map.removeLayer(markers[activeDeviceId]);
      
      // Update registry sidebar status
      const activeItem = document.querySelector('.device-item.active');
      if (activeItem) {
        activeItem.querySelector('p').innerHTML = `<i class="fa-solid fa-triangle-exclamation" style="color:#f87171"></i> DEVICE WIPED / OFFLINE`;
        activeItem.querySelector('.device-battery').style.color = '#f87171';
        activeItem.querySelector('.device-battery').textContent = '0%';
      }

      logConsole(`[SUCCESS]: ${device.name} wiped completely. Connection severed.`, 'success');
      
      // Show wiped state on phone mockup
      const screenContent = document.querySelector('.screen-content');
      screenContent.innerHTML = `
        <i class="fa-solid fa-circle-radiation" style="font-size: 64px; color: var(--text-muted); margin-bottom: 20px;"></i>
        <h3 style="color:var(--text-muted)">Wipe Complete</h3>
        <p>No operating system detected. All memory blocks scrubbed.</p>
        <button id="reset-mock-phone-wiped" style="background:var(--accent-cyan); color:#000; padding:8px 16px; border:none; border-radius:4px; font-weight:600; cursor:pointer;">Reset Demo Screen</button>
      `;

      document.getElementById('reset-mock-phone-wiped').addEventListener('click', () => {
        location.reload(); // Reload to restore markers
      });

    }, 2200);
  });

  // Reset Mock Phone visual state helper
  function resetMockPhoneVisual() {
    const screenContent = document.querySelector('.screen-content');
    screenContent.innerHTML = `
      <i class="fa-solid fa-circle-check check-shield"></i>
      <h3>ARCHBRAIN Secured</h3>
      <p>Agent tracking is active in background</p>
      <div class="pulse-indicator"></div>
    `;
    logConsole("[SYSTEM]: Simulator display reset to default state.");
  }

  // Push MDM Policies button
  document.getElementById('save-policy-btn').addEventListener('click', () => {
    logConsole("[MDM]: Encoding security policy packages...");
    setTimeout(() => {
      logConsole("[SUCCESS]: Security policies pushed and applied to enrolled devices.", 'success');
      alert("Corporate MDM policies pushed successfully!");
    }, 600);
  });

  // 4. Pricing Toggle (Personal vs Business)
  const togglePersonal = document.getElementById('toggle-personal');
  const toggleBusiness = document.getElementById('toggle-business');
  const personalGrid = document.getElementById('pricing-personal-grid');
  const businessGrid = document.getElementById('pricing-business-grid');
  const pricingNote = document.getElementById('pricing-note');

  togglePersonal.addEventListener('click', () => {
    togglePersonal.classList.add('active');
    toggleBusiness.classList.remove('active');
    personalGrid.classList.remove('hidden');
    businessGrid.classList.add('hidden');
    pricingNote.classList.remove('hidden');
  });

  toggleBusiness.addEventListener('click', () => {
    toggleBusiness.classList.add('active');
    togglePersonal.classList.remove('active');
    businessGrid.classList.remove('hidden');
    personalGrid.classList.add('hidden');
    pricingNote.classList.add('hidden');
  });

  // 5. Accordion FAQs
  const faqItems = document.querySelectorAll('.faq-item');
  faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');
    question.addEventListener('click', () => {
      // Toggle sibling items off
      const isActive = item.classList.contains('active');
      faqItems.forEach(el => el.classList.remove('active'));
      
      if (!isActive) {
        item.classList.add('active');
      }
    });
  });

  // 6. Privacy Policy Modal triggers
  const privacyModal = document.getElementById('privacy-modal');
  const viewPrivacyBtn = document.getElementById('view-privacy-btn');
  const closePrivacyBtn = document.getElementById('close-privacy-btn');

  if (viewPrivacyBtn) {
    viewPrivacyBtn.addEventListener('click', (e) => {
      e.preventDefault();
      if (privacyModal) privacyModal.classList.add('active');
    });
  }

  if (closePrivacyBtn) {
    closePrivacyBtn.addEventListener('click', () => {
      if (privacyModal) privacyModal.classList.remove('active');
    });
  }

  // Close modal when clicking outside contents
  if (privacyModal) {
    privacyModal.addEventListener('click', (e) => {
      if (e.target === privacyModal) {
        privacyModal.classList.remove('active');
      }
    });
  }

  // 6.2 Terms & Conditions Modal triggers
  const termsModal = document.getElementById('terms-modal');
  const viewTermsBtn = document.getElementById('view-terms-btn');
  const closeTermsBtn = document.getElementById('close-terms-btn');

  if (viewTermsBtn) {
    viewTermsBtn.addEventListener('click', (e) => {
      e.preventDefault();
      if (termsModal) termsModal.classList.add('active');
    });
  }

  if (closeTermsBtn) {
    closeTermsBtn.addEventListener('click', () => {
      if (termsModal) termsModal.classList.remove('active');
    });
  }

  if (termsModal) {
    termsModal.addEventListener('click', (e) => {
      if (e.target === termsModal) {
        termsModal.classList.remove('active');
      }
    });
  }

  // 7. Paystack Simulation Logic
  const paystackModal = document.getElementById('paystack-modal');
  const closePaystackBtn = document.getElementById('close-paystack-btn');
  const paystackPlanName = document.getElementById('paystack-plan-name');
  const paystackAmountText = document.getElementById('paystack-amount-text');
  const paystackEmailText = document.getElementById('paystack-email-text');
  const paystackBtnAmount = document.getElementById('paystack-btn-amount');
  const btnPaystackSubmit = document.getElementById('btn-paystack-submit');

  let selectedPlan = '';

  function openPaystack(plan, amount, email) {
    selectedPlan = plan;
    if (paystackPlanName) paystackPlanName.textContent = plan;
    if (paystackAmountText) paystackAmountText.textContent = amount;
    if (paystackEmailText) paystackEmailText.textContent = email;
    if (paystackBtnAmount) paystackBtnAmount.textContent = amount;
    if (paystackModal) paystackModal.classList.add('active');
  }

  const btnBuyFree = document.getElementById('btn-buy-free');
  const btnBuyPremium = document.getElementById('btn-buy-premium');
  const btnBuyBusiness = document.getElementById('btn-buy-business');

  if (btnBuyFree) {
    btnBuyFree.addEventListener('click', (e) => {
      e.preventDefault();
      openPaystack('Free Trial Plan', '₦0', 'rider@archbrain.com');
    });
  }

  if (btnBuyPremium) {
    btnBuyPremium.addEventListener('click', (e) => {
      e.preventDefault();
      openPaystack('Premium Protection Plan', '₦2,500', 'biker@archbrain.com');
    });
  }

  if (btnBuyBusiness) {
    btnBuyBusiness.addEventListener('click', (e) => {
      e.preventDefault();
      openPaystack('Business MDM Plan', '₦15,000', 'admin@kongadeliveries.com');
    });
  }

  if (closePaystackBtn) {
    closePaystackBtn.addEventListener('click', () => {
      if (paystackModal) paystackModal.classList.remove('active');
    });
  }

  if (paystackModal) {
    paystackModal.addEventListener('click', (e) => {
      if (e.target === paystackModal) {
        paystackModal.classList.remove('active');
      }
    });
  }

  if (btnPaystackSubmit) {
    btnPaystackSubmit.addEventListener('click', () => {
      btnPaystackSubmit.disabled = true;
      btnPaystackSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Processing payment...';
      
      setTimeout(() => {
        btnPaystackSubmit.style.backgroundColor = '#10b981';
        btnPaystackSubmit.innerHTML = '<i class="fa-solid fa-circle-check"></i> Payment Successful!';
        
        setTimeout(() => {
          if (paystackModal) paystackModal.classList.remove('active');
          
          btnPaystackSubmit.disabled = false;
          btnPaystackSubmit.style.backgroundColor = '';
          const amt = paystackAmountText ? paystackAmountText.textContent : '₦15,000';
          btnPaystackSubmit.innerHTML = `Pay <span id="paystack-btn-amount">${amt}</span>`;

          if (selectedPlan === 'Business MDM Plan') {
            alert('Payment Successful via Paystack!\nRedirecting you to the ARCHBRAIN Business MDM Dashboard Console...');
            window.location.href = 'http://localhost:3005';
          } else {
            alert(`Payment of ${amt} processed successfully!\nUnlocking your simulation console...`);
            const demoSec = document.getElementById('demo');
            if (demoSec) demoSec.scrollIntoView({ behavior: 'smooth' });
          }
        }, 1000);
      }, 1500);
    });
  }

  // 8. Rotating Network Globe Canvas
  const canvas = document.getElementById('network-globe-canvas');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    let width = canvas.offsetWidth;
    let height = canvas.offsetHeight;
    
    // Set internal size to match CSS size * devicePixelRatio
    const dpr = window.devicePixelRatio || 1;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    ctx.scale(dpr, dpr);

    let points = [];
    const baseRadius = 160;
    const segmentsLat = 18;
    const segmentsLon = 24;

    // Generate unit vectors (radius = 1) for the sphere's grid dots
    for (let i = 0; i <= segmentsLat; i++) {
      let theta = (i / segmentsLat) * Math.PI - Math.PI / 2;
      for (let j = 0; j < segmentsLon; j++) {
        let phi = (j / segmentsLon) * 2 * Math.PI - Math.PI;
        
        let ux = Math.cos(theta) * Math.sin(phi);
        let uy = -Math.sin(theta);
        let uz = Math.cos(theta) * Math.cos(phi);
        
        points.push({ ux, uy, uz });
      }
    }

    // City nodes inside Nigeria
    const cities = [
      { name: 'Lagos', lat: 6.5244, lon: 3.3792, pulse: 0 },
      { name: 'Abuja', lat: 9.0765, lon: 7.3986, pulse: 0.3 },
      { name: 'Port Harcourt', lat: 4.8156, lon: 7.0498, pulse: 0.6 },
      { name: 'Kano', lat: 12.0022, lon: 8.5920, pulse: 0.1 },
      { name: 'Enugu', lat: 6.4281, lon: 7.4951, pulse: 0.8 }
    ];

    // Convert city coordinates to unit vectors
    const lonOffset = -8.6; // shift longitude so Nigeria center is initially facing forward
    const cityNodes = cities.map(city => {
      let latRad = (city.lat) * Math.PI / 180;
      let lonRad = (city.lon + lonOffset) * Math.PI / 180;
      
      let ux = Math.cos(latRad) * Math.sin(lonRad);
      let uy = -Math.sin(latRad);
      let uz = Math.cos(latRad) * Math.cos(lonRad);
      
      return {
        name: city.name,
        ux, uy, uz,
        pulseSpeed: 0.015,
        pulseVal: city.pulse
      };
    });

    // Connections between cities
    const connections = [
      { from: 'Lagos', to: 'Abuja' },
      { from: 'Abuja', to: 'Kano' },
      { from: 'Lagos', to: 'Port Harcourt' },
      { from: 'Port Harcourt', to: 'Enugu' },
      { from: 'Enugu', to: 'Abuja' }
    ];

    let angleX = 0.25; // vertical rotation
    let angleY = 0; // horizontal rotation
    const rotationSpeed = 0.004;

    // Interactive Drag / Touch controls
    let isDragging = false;
    let previousMousePosition = { x: 0, y: 0 };
    let autoRotationActive = true;
    let autoRotationTimer = null;

    canvas.style.cursor = 'grab';

    // Drag start helper
    function startDrag(x, y) {
      isDragging = true;
      previousMousePosition = { x, y };
      autoRotationActive = false;
      canvas.style.cursor = 'grabbing';
      if (autoRotationTimer) clearTimeout(autoRotationTimer);
    }

    // Drag move helper
    function moveDrag(x, y) {
      if (!isDragging) return;
      const deltaX = x - previousMousePosition.x;
      const deltaY = y - previousMousePosition.y;
      
      // Horizontal drag maps to Y rotation, vertical drag maps to X rotation
      angleY += deltaX * 0.008;
      angleX += deltaY * 0.008;
      
      // Limit vertical tilt to prevent flipping upside down
      const maxTilt = Math.PI / 2.5; // ~72 degrees
      if (angleX > maxTilt) angleX = maxTilt;
      if (angleX < -maxTilt) angleX = -maxTilt;

      previousMousePosition = { x, y };
    }

    // Drag end helper
    function endDrag() {
      if (!isDragging) return;
      isDragging = false;
      canvas.style.cursor = 'grab';
      
      // Resume auto rotation after 3s
      autoRotationTimer = setTimeout(() => {
        autoRotationActive = true;
      }, 3000);
    }

    // Mouse Drag Listeners
    canvas.addEventListener('mousedown', (e) => {
      const rect = canvas.getBoundingClientRect();
      startDrag(e.clientX - rect.left, e.clientY - rect.top);
    });

    window.addEventListener('mousemove', (e) => {
      if (!isDragging) return;
      const rect = canvas.getBoundingClientRect();
      moveDrag(e.clientX - rect.left, e.clientY - rect.top);
    });

    window.addEventListener('mouseup', () => {
      endDrag();
    });

    // Mouse Wheel Zoom (with preventDefault to avoid window scroll interference)
    let pinchScale = 1.0;
    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      pinchScale += e.deltaY * -0.0015;
      // Clamp pinch zoom
      pinchScale = Math.max(0.8, Math.min(3.0, pinchScale));
      
      autoRotationActive = false;
      if (autoRotationTimer) clearTimeout(autoRotationTimer);
      autoRotationTimer = setTimeout(() => {
        autoRotationActive = true;
      }, 3000);
    }, { passive: false });

    // Touch Events for Drag-to-rotate and Pinch-to-zoom (Two fingers)
    let initialPinchDistance = 0;
    let startPinchScale = 1.0;

    canvas.addEventListener('touchstart', (e) => {
      if (e.touches.length === 1) {
        const rect = canvas.getBoundingClientRect();
        startDrag(e.touches[0].clientX - rect.left, e.touches[0].clientY - rect.top);
      } else if (e.touches.length === 2) {
        // Initialize two-finger pinch-to-zoom gesture
        isDragging = false;
        const dx = e.touches[0].clientX - e.touches[1].clientX;
        const dy = e.touches[0].clientY - e.touches[1].clientY;
        initialPinchDistance = Math.hypot(dx, dy);
        startPinchScale = pinchScale;
        
        autoRotationActive = false;
        if (autoRotationTimer) clearTimeout(autoRotationTimer);
      }
    }, { passive: true });

    canvas.addEventListener('touchmove', (e) => {
      if (e.touches.length === 1 && isDragging) {
        const rect = canvas.getBoundingClientRect();
        moveDrag(e.touches[0].clientX - rect.left, e.touches[0].clientY - rect.top);
      } else if (e.touches.length === 2 && initialPinchDistance > 0) {
        const dx = e.touches[0].clientX - e.touches[1].clientX;
        const dy = e.touches[0].clientY - e.touches[1].clientY;
        const currentDistance = Math.hypot(dx, dy);
        
        pinchScale = startPinchScale * (currentDistance / initialPinchDistance);
        pinchScale = Math.max(0.8, Math.min(3.0, pinchScale));
      }
    }, { passive: true });

    canvas.addEventListener('touchend', (e) => {
      if (e.touches.length === 0) {
        endDrag();
        initialPinchDistance = 0;
      } else if (e.touches.length === 1) {
        // Gracefully shift back to single-finger drag
        const rect = canvas.getBoundingClientRect();
        previousMousePosition = {
          x: e.touches[0].clientX - rect.left,
          y: e.touches[0].clientY - rect.top
        };
        isDragging = true;
      }
    });

    // Dynamic scale expansion on scroll
    let scrollScale = 1.0;
    function updateScrollScale() {
      const rect = canvas.getBoundingClientRect();
      const windowHeight = window.innerHeight;
      
      if (rect.top < windowHeight && rect.bottom > 0) {
        const progress = (windowHeight - rect.top) / (windowHeight + rect.height);
        // Expand/zoom scroll offset
        scrollScale = 0.85 + progress * 0.4;
      }
    }
    
    window.addEventListener('scroll', updateScrollScale, { passive: true });
    updateScrollScale(); // initial scroll trigger

    // Leaflet configuration for city map overlays
    const mapOverlays = {
      'Lagos': { coords: [6.5244, 3.3792], zoom: 12 },
      'Abuja': { coords: [9.0765, 7.3986], zoom: 12 },
      'Port Harcourt': { coords: [4.8156, 7.0498], zoom: 12 },
      'Kano': { coords: [12.0022, 8.5920], zoom: 12 },
      'Enugu': { coords: [6.4281, 7.4951], zoom: 12 }
    };

    const overlayMaps = {};
    
    Object.keys(mapOverlays).forEach(cityName => {
      const info = mapOverlays[cityName];
      const domId = `map-overlay-${cityName.replace(/\s+/g, '')}`;
      const el = document.getElementById(domId);
      if (el) {
        const m = L.map(domId, {
          zoomControl: false,
          attributionControl: false,
          dragging: false,
          touchZoom: false,
          doubleClickZoom: false,
          scrollWheelZoom: false
        }).setView(info.coords, info.zoom);

        // Add CartoDB Dark Matter tile layer
        L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
          maxZoom: 19
        }).addTo(m);

        // Add orange circular marker
        L.circleMarker(info.coords, {
          color: '#ff7a00',
          fillColor: '#ff7a00',
          fillOpacity: 0.8,
          radius: 4
        }).addTo(m);

        overlayMaps[cityName] = {
          mapInstance: m,
          domEl: el,
          initialized: false
        };
      }
    });

    function hideMapOverlay(overlay) {
      overlay.domEl.style.opacity = 0;
      overlay.domEl.style.transform = `translate(-50%, -50%) scale(0)`;
      overlay.domEl.style.pointerEvents = 'none';
      overlay.initialized = false;
    }

    // Resize handler
    window.addEventListener('resize', () => {
      width = canvas.offsetWidth;
      height = canvas.offsetHeight;
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      ctx.setTransform(1, 0, 0, 1, 0, 0); // reset scale
      ctx.scale(dpr, dpr);
    });

    function animate() {
      ctx.clearRect(0, 0, width, height);

      const centerX = width / 2;
      const centerY = height / 2;
      const FOV = 450; // perspective field of view

      // Increment rotation automatically if user is not actively dragging
      if (autoRotationActive) {
        angleY += rotationSpeed;
      }

      // Calculate aggregate zoom scale (scroll zoom * pinch/scrollwheel zoom)
      const currentScale = scrollScale * pinchScale;
      const currentRadius = baseRadius * currentScale;

      // Draw connections first
      connections.forEach(conn => {
        const fromNode = cityNodes.find(n => n.name === conn.from);
        const toNode = cityNodes.find(n => n.name === conn.to);
        
        if (fromNode && toNode) {
          const xA = fromNode.ux * currentRadius;
          const yA = fromNode.uy * currentRadius;
          const zA = fromNode.uz * currentRadius;

          const xB = toNode.ux * currentRadius;
          const yB = toNode.uy * currentRadius;
          const zB = toNode.uz * currentRadius;

          // Rotate Node A
          let x1A = xA * Math.cos(angleY) - zA * Math.sin(angleY);
          let z1A = xA * Math.sin(angleY) + zA * Math.cos(angleY);
          let y2A = yA * Math.cos(angleX) - z1A * Math.sin(angleX);
          let z2A = yA * Math.sin(angleX) + z1A * Math.cos(angleX);

          // Rotate Node B
          let x1B = xB * Math.cos(angleY) - zB * Math.sin(angleY);
          let z1B = xB * Math.sin(angleY) + zB * Math.cos(angleY);
          let y2B = yB * Math.cos(angleX) - z1B * Math.sin(angleX);
          let z2B = yB * Math.sin(angleX) + z1B * Math.cos(angleX);

          // Render only if both are on the front hemisphere
          if (z2A > -50 && z2B > -50) {
            let scaleA = FOV / (FOV + z2A);
            let screenXA = centerX + x1A * scaleA;
            let screenYA = centerY + y2A * scaleA;

            let scaleB = FOV / (FOV + z2B);
            let screenXB = centerX + x1B * scaleB;
            let screenYB = centerY + y2B * scaleB;

            // Draw curved connection line
            ctx.beginPath();
            ctx.moveTo(screenXA, screenYA);
            
            let midX = (screenXA + screenXB) / 2;
            let midY = (screenYA + screenYB) / 2;
            let dx = screenXB - screenXA;
            let dy = screenYB - screenYA;
            let dist = Math.sqrt(dx * dx + dy * dy);
            
            let nx = -dy / dist;
            let ny = dx / dist;
            let bend = dist * 0.15; // arc curve magnitude
            
            let cpX = midX + nx * bend;
            let cpY = midY + ny * bend;
            
            ctx.quadraticCurveTo(cpX, cpY, screenXB, screenYB);
            ctx.strokeStyle = 'rgba(255, 122, 0, 0.35)';
            ctx.lineWidth = 1.2 * currentScale;
            ctx.stroke();
          }
        }
      });

      // Draw background points (z <= 0)
      points.forEach(pt => {
        const x = pt.ux * currentRadius;
        const y = pt.uy * currentRadius;
        const z = pt.uz * currentRadius;

        let x1 = x * Math.cos(angleY) - z * Math.sin(angleY);
        let z1 = x * Math.sin(angleY) + z * Math.cos(angleY);
        let y2 = y * Math.cos(angleX) - z1 * Math.sin(angleX);
        let z2 = y * Math.sin(angleX) + z1 * Math.cos(angleX);

        if (z2 <= 0) {
          let scale = FOV / (FOV + z2);
          let screenX = centerX + x1 * scale;
          let screenY = centerY + y2 * scale;
          
          ctx.beginPath();
          ctx.arc(screenX, screenY, 0.8 * currentScale, 0, 2 * Math.PI);
          ctx.fillStyle = 'rgba(0, 242, 254, 0.12)';
          ctx.fill();
        }
      });

      // Draw foreground points (z > 0)
      points.forEach(pt => {
        const x = pt.ux * currentRadius;
        const y = pt.uy * currentRadius;
        const z = pt.uz * currentRadius;

        let x1 = x * Math.cos(angleY) - z * Math.sin(angleY);
        let z1 = x * Math.sin(angleY) + z * Math.cos(angleY);
        let y2 = y * Math.cos(angleX) - z1 * Math.sin(angleX);
        let z2 = y * Math.sin(angleX) + z1 * Math.cos(angleX);

        if (z2 > 0) {
          let scale = FOV / (FOV + z2);
          let screenX = centerX + x1 * scale;
          let screenY = centerY + y2 * scale;
          
          ctx.beginPath();
          ctx.arc(screenX, screenY, 1.2 * currentScale, 0, 2 * Math.PI);
          ctx.fillStyle = 'rgba(0, 242, 254, 0.45)';
          ctx.fill();
        }
      });

      // Draw city nodes
      cityNodes.forEach(node => {
        const x = node.ux * currentRadius;
        const y = node.uy * currentRadius;
        const z = node.uz * currentRadius;

        let x1 = x * Math.cos(angleY) - z * Math.sin(angleY);
        let z1 = x * Math.sin(angleY) + z * Math.cos(angleY);
        let y2 = y * Math.cos(angleX) - z1 * Math.sin(angleX);
        let z2 = y * Math.sin(angleX) + z1 * Math.cos(angleX);

        const mapOverlay = overlayMaps[node.name];

        if (z2 > 0) {
          let scale = FOV / (FOV + z2);
          let screenX = centerX + x1 * scale;
          let screenY = centerY + y2 * scale;

          // Pulse animation logic
          node.pulseVal += node.pulseSpeed;
          if (node.pulseVal > 1) node.pulseVal = 0;
          let pulseRadius = (5 + node.pulseVal * 12) * currentScale;
          let pulseOpacity = 1 - node.pulseVal;

          // Draw pulsing outer ring
          ctx.beginPath();
          ctx.arc(screenX, screenY, pulseRadius, 0, 2 * Math.PI);
          ctx.strokeStyle = `rgba(255, 122, 0, ${pulseOpacity * 0.7})`;
          ctx.lineWidth = 1.5;
          ctx.stroke();

          // Draw solid inner dot
          ctx.beginPath();
          ctx.arc(screenX, screenY, 4 * currentScale, 0, 2 * Math.PI);
          ctx.fillStyle = 'rgb(255, 122, 0)';
          ctx.fill();

          // Draw city name label
          ctx.fillStyle = 'rgba(255, 255, 255, 0.95)';
          ctx.font = `600 ${Math.max(9, 11 * currentScale)}px Inter, sans-serif`;
          ctx.textAlign = 'left';
          ctx.fillText(node.name, screenX + 8 * currentScale, screenY + 3 * currentScale);

          // Position and render circular HTML maps
          if (mapOverlay) {
            // Trigger maps when zoomed in past threshold (currentScale > 1.4)
            if (currentScale > 1.4) {
              const scaleProgress = Math.min(1.0, (currentScale - 1.4) * 1.5);
              
              if (scaleProgress > 0) {
                // Position map div centered 70px above the city dot
                mapOverlay.domEl.style.left = `${screenX}px`;
                mapOverlay.domEl.style.top = `${screenY - 70}px`;
                mapOverlay.domEl.style.opacity = scaleProgress;
                mapOverlay.domEl.style.transform = `translate(-50%, -50%) scale(${scaleProgress})`;
                mapOverlay.domEl.style.pointerEvents = scaleProgress > 0.8 ? 'auto' : 'none';

                if (!mapOverlay.initialized) {
                  mapOverlay.mapInstance.invalidateSize();
                  mapOverlay.initialized = true;
                }
              } else {
                hideMapOverlay(mapOverlay);
              }
            } else {
              hideMapOverlay(mapOverlay);
            }
          }
        } else {
          if (mapOverlay) {
            hideMapOverlay(mapOverlay);
          }
        }
      });

      requestAnimationFrame(animate);
    }

    animate();
  }

});
