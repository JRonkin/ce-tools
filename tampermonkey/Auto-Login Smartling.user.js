// ==UserScript==
// @name         Auto-Login Smartling
// @namespace    jronkin.ce_tools
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/ce-tools/raw/master/tampermonkey/Auto-Login%20Smartling.user.js
// @description  Automatically click the Smartling "Sign In With Google" button
// @author       Jason Ronkin
// @match        https://sso.smartling.com/auth/realms/Smartling/protocol/openid-connect/auth*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
  'use strict';

  document.getElementById('zocial-google').click();
})();