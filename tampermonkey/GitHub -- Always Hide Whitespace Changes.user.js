// ==UserScript==
// @name         GitHub -- Always Hide Whitespace Changes
// @namespace    jronkin.ce_tools
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/ce-tools/raw/master/tampermonkey/GitHub%20--%20Always%20Hide%20Whitespace%20Changes.user.js
// @description  Always hide whitespace changes when viewing diffs and pull requests
// @author       Jason Ronkin
// @match        https://github.com/*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
  'use strict';

  var whitespaceCb = document.getElementById('whitespace-cb');
  if (whitespaceCb) {
    whitespaceCb.checked = true;
  }
})();