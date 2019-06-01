// ==UserScript==
// @name         Storm -- Unlimit Site Attributes
// @namespace    jronkin.ce_tools
// @version      1.0.0
// @downloadUrl  https://github.com/JRonkin/ce-tools/raw/master/tampermonkey/Storm%20--%20Unlimit%20Site%20Attributes.user.js
// @description  Set the query param "limit=none" when viewing site attributes in Storm
// @author       Jason Ronkin
// @match        https://www.yext.com/s/*/storepages/site/*/attributes*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
  'use strict';

  var search = new URLSearchParams(window.location.search);
  if (search.get('limit') != 'none') {
    search.set('limit', 'none');
    window.location.search = search.toString();
  }
})();