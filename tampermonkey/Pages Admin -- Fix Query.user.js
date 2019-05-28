// ==UserScript==
// @name         Pages Admin -- Fix Query
// @namespace    jronkin.yext
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/yext-ce-tools/raw/master/tampermonkey/Pages%20Admin%20--%20Fix%20Query.user.js
// @description  Bring back the functionality to search with query parameter, as in "?query=%s"
// @author       You
// @match        https://www.yext.com/pagesadmin*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
  'use strict';

  var input = document.querySelector('#sites_table_filter input');
  input.value = new URLSearchParams(window.location.search).get('query');
  input.dispatchEvent(new Event('keyup'));
})();