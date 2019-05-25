// ==UserScript==
// @name         JIRA -- No Notification Badge
// @namespace    https://github.com/JRonkin/yext-ce-tools
// @version      1.0
// @description  Hide the notification badge in JIRA
// @author       You
// @match        https://*.atlassian.net/*
// @grant        GM_addStyle
// @run-at       document-start
// ==/UserScript==

(function() {
  'use strict';

  GM_addStyle('.css-v2uvap { display: none; }');
})();