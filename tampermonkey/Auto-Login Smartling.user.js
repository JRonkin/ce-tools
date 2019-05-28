// ==UserScript==
// @name         Auto-Login Smartling
// @namespace    jronkin.yext
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/yext-ce-tools/raw/master/tampermonkey/Auto-Login%20Smartling.user.js
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