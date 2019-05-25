// ==UserScript==
// @name         Auto-Login Smartling
// @namespace    https://github.com/JRonkin/yext-ce-tools
// @version      1.0
// @description  Automatically click the Smartling "Sign In With Google" button
// @author       You
// @match        https://sso.smartling.com/auth/realms/Smartling/protocol/openid-connect/auth*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
  'use strict';

  document.getElementById('zocial-google').click();
})();