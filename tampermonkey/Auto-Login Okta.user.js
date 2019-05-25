// ==UserScript==
// @name         Auto-Login Okta
// @namespace    https://github.com/JRonkin/yext-ce-tools
// @version      1.0
// @description  Automatically click the Okta login button
// @author       You
// @match        https://yext.okta.com/login/login.htm*
// @grant        none
// @run-at:      document-end
// ==/UserScript==

(function() {
  'use strict';

  var pwInput = document.getElementById('okta-signin-password');
  if (pwInput.value) {
    setTimeout(() => pwInput.form.dispatchEvent(new Event('submit')), 100);
  } else {
    pwInput.addEventListener('change', () => {
      if (pwInput.value) {
        setTimeout(() => pwInput.form.dispatchEvent(new Event('submit')), 100);
      }
    });
  }
})();