// ==UserScript==
// @name         GitHub -- Always Hide Whitespace Changes
// @namespace    https://github.com/JRonkin/yext-ce-tools
// @version      1.0
// @description  Always hide whitespace changes when viewing diffs and pull requests
// @author       You
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