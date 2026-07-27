document.addEventListener('DOMContentLoaded', () => {
  const loginView = document.getElementById('login-view');
  const signupView = document.getElementById('signup-view');
  const headerActionBtn = document.getElementById('header-action-btn');
  
  const linkToSignup = document.getElementById('link-to-signup');
  const linkToLogin = document.getElementById('link-to-login');

  // Toggle View Handler
  function switchView(mode) {
    if (mode === 'signup') {
      loginView.classList.remove('active');
      signupView.classList.add('active');
      headerActionBtn.textContent = 'Support';
      headerActionBtn.href = '../website/contact.html'; // Points to main site contact page
      // Update browser URL query param without reload
      history.pushState(null, '', '?mode=signup');
    } else {
      signupView.classList.remove('active');
      loginView.classList.add('active');
      headerActionBtn.textContent = 'Sign up';
      headerActionBtn.href = '#';
      history.pushState(null, '', '?mode=login');
    }
  }

  // Bind clicks
  linkToSignup.addEventListener('click', (e) => {
    e.preventDefault();
    switchView('signup');
  });

  linkToLogin.addEventListener('click', (e) => {
    e.preventDefault();
    switchView('login');
  });

  headerActionBtn.addEventListener('click', (e) => {
    if (headerActionBtn.textContent === 'Sign up') {
      e.preventDefault();
      switchView('signup');
    }
  });

  // Check URL query parameters on load
  const urlParams = new URLSearchParams(window.location.search);
  const initialMode = urlParams.get('mode');
  if (initialMode === 'signup') {
    switchView('signup');
  } else {
    switchView('login');
  }

  // Password Visibility Toggle
  document.querySelectorAll('.toggle-password').forEach(icon => {
    icon.addEventListener('click', () => {
      const targetId = icon.getAttribute('data-target');
      const passwordInput = document.getElementById(targetId);
      
      if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
      } else {
        passwordInput.type = 'password';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
      }
    });
  });

  // CAPTCHA Mock Animation (Verify you are human Turnstile)
  const captchaCheckbox = document.getElementById('captcha-checkbox');
  const checkmark = document.querySelector('.checkmark');
  const captchaLabel = document.querySelector('.captcha-label');

  if (captchaCheckbox) {
    captchaCheckbox.addEventListener('change', () => {
      if (captchaCheckbox.checked) {
        // Disable temporary to avoid multi-trigger
        captchaCheckbox.disabled = true;
        checkmark.classList.add('loading');
        captchaLabel.textContent = 'Verifying...';

        setTimeout(() => {
          checkmark.classList.remove('loading');
          checkmark.style.backgroundColor = '#10b981';
          checkmark.style.borderColor = '#10b981';
          captchaLabel.textContent = 'Verified!';
          captchaCheckbox.disabled = false;
        }, 1200);
      } else {
        checkmark.style.backgroundColor = '';
        checkmark.style.borderColor = '';
        captchaLabel.textContent = 'Verify you are human';
      }
    });
  }

  // Form Submissions
  const loginForm = document.getElementById('login-form');
  const signupForm = document.getElementById('signup-form');

  loginForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const btn = loginForm.querySelector('.btn-auth-submit');
    const originalText = btn.textContent;
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Authenticating...';
    btn.style.opacity = '0.8';

    setTimeout(() => {
      // Redirect to the dashboard
      window.location.href = 'dashboard.html';
    }, 1000);
  });

  signupForm.addEventListener('submit', (e) => {
    e.preventDefault();
    
    // Check if CAPTCHA is checked
    if (!captchaCheckbox.checked || checkmark.classList.contains('loading')) {
      alert('Please complete the verification checkbox first.');
      return;
    }

    const btn = signupForm.querySelector('.btn-auth-submit');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Creating Account...';
    btn.style.opacity = '0.8';

    setTimeout(() => {
      // Redirect to dashboard
      window.location.href = 'dashboard.html';
    }, 1000);
  });

});
