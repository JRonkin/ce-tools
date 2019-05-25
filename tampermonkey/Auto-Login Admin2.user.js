// ==UserScript==
// @name         Auto-Login Admin2
// @namespace    https://github.com/JRonkin/yext-ce-tools
// @version      1.0
// @description  Automatically click the login link when switching accounts in Admin2
// @author       You
// @match        https://www.yext.com/users/accessdenied*
// @grant        none
// @run-at:      document-end
// ==/UserScript==

(function() {
  'use strict';

  document.querySelector('.js-signin-url').click();
})();