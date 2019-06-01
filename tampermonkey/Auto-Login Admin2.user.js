// ==UserScript==
// @name         Auto-Login Admin2
// @namespace    jronkin.ce_tools
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/ce-tools/raw/master/tampermonkey/Auto-Login%20Admin2.user.js
// @description  Automatically click the login link when switching accounts in Admin2
// @author       Jason Ronkin
// @match        https://www.yext.com/users/accessdenied*
// @grant        none
// @run-at:      document-end
// ==/UserScript==

(function() {
  'use strict';

  document.querySelector('.js-signin-url').click();
})();
