// ==UserScript==
// @name         Pages Admin -- Fix Query
// @namespace    https://github.com/JRonkin/yext-ce-tools
// @version      1.0
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