// ==UserScript==
// @name         Auto-Login GitHub SSO
// @namespace    jronkin.ce_tools
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/ce-tools/raw/master/tampermonkey/Auto-Login%20GitHub%20SSO.user.js
// @description  Automatically click the SSO link when it appears
// @author       Jason Ronkin
// @match        https://github.com
// @match        https://github.com/*
// @grant        none
// @run-at:      document-end
// ==/UserScript==

(function() {
  'use strict';

  var ssoLink = document.querySelector('.note a');
  var form = document.querySelector('form');

  if (ssoLink && /^https:\/\/github\.com\/orgs\/[^/]+\/sso/.test(ssoLink.href)) {
    ssoLink.click();
  } else if (form && /^https:\/\/github\.com\/orgs\/[^/]+\/saml\/initiate/.test(form.action)) {
    form.submit();
  }
})();
