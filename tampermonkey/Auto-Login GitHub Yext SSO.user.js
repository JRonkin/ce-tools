// ==UserScript==
// @name         Auto-Login GitHub Yext SSO
// @namespace    jronkin.yext
// @version      1.0
// @downloadUrl  https://github.com/JRonkin/yext-ce-tools/raw/master/tampermonkey/Auto-Login%20GitHub%20Yext%20SSO.user.js
// @description  Automatically click the SSO link when it appears
// @author       You
// @match        https://github.com/*
// @grant        none
// @run-at:      document-end
// ==/UserScript==

(function() {
  'use strict';

  var ssoLink = document.querySelector('.note a');
  if (ssoLink && ssoLink.href.indexOf('https://github.com/orgs/yext/sso') == 0) {
    ssoLink.click();
  }

  var form = document.querySelector('form');
  if (form && form.action.indexOf('https://github.com/orgs/yext/saml/initiate') == 0) {
    form.submit();
  }
})();