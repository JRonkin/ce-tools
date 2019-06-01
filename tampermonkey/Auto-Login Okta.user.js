// ==UserScript==
// @name         Auto-Login Okta
// @namespace    jronkin.ce_tools
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/ce-tools/raw/master/tampermonkey/Auto-Login%20Okta.user.js
// @description  Automatically click the Okta login button -- NOTE: Must have browser auto-fill username and password
// @author       Jason Ronkin
// @match        https://*.okta.com/login/login.htm*
// @grant        none
// @run-at:      document-idle
// ==/UserScript==

(function() {
  'use strict';

  var pwInput = document.getElementById('okta-signin-password');

  function handler() {
    if (pwInput.value) {
      setTimeout(() => pwInput.form.dispatchEvent(new Event('submit')), 100);
    } else {
      pwInput.addEventListener('change', () => {
        if (pwInput.value) {
          setTimeout(() => pwInput.form.dispatchEvent(new Event('submit')), 100);
        }
      });
    }
  }

  if (pwInput) {
    handler();
  } else {
    window.addEventListener('DOMNodeInserted', function(e) {
      pwInput = document.getElementById('okta-signin-password');
      if (pwInput) {
        handler();
      }
    });
  }
})();
