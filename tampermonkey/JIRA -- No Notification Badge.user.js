// ==UserScript==
// @name         JIRA -- No Notification Badge
// @namespace    jronkin.yext
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/yext-ce-tools/raw/master/tampermonkey/JIRA%20--%20No%20Notification%20Badge.user.js
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