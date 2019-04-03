const scripts = [
  { exec: Auto_GitHub_SSO, site: 'https://github.com/' },
  { exec: Auto_Login_Admin2, site: 'https://www.yext.com/users/accessdenied' },
  { exec: Auto_Login_Okta, site: 'https://yext.okta.com/login/login.htm' },
  { exec: Auto_Login_Smartling, site: 'https://sso.smartling.com/auth/realms/Smartling/protocol/openid-connect/auth' },
  { exec: Fix_Pages_Admin_Query, site: 'https://www.yext.com/pagesadmin' },
  { exec: No_JIRA_Notification_Badge, site: 'https://yexttest.atlassian.net' }
];


for (let script of scripts) {
  if (window.location.href.indexOf(script.site) == 0) {
    script.exec();
  }
}


function Auto_GitHub_SSO() {
  const form = document.querySelector('form');
  if (form && form.action.indexOf('https://github.com/orgs/yext/saml/initiate') == 0) {
    form.submit();
  }
}

    
function Auto_Login_Admin2() {
  document.querySelector('.js-signin-url').click();
}


function Auto_Login_Okta() {
  const i = setInterval(() => {
    if (document.getElementById('okta-signin-password').value) {
      document.getElementById('okta-signin-submit').click();
      clearInterval(i);
    }
  }, 200);
}


function Auto_Login_Smartling() {
  document.getElementById('zocial-google').click();
}


function Fix_Pages_Admin_Query() {
  const input = document.querySelector('#sites_table_filter input');
  input.value = (new URLSearchParams(window.location.search)).get('query');
  input.dispatchEvent(new Event('keyup'));
}


function No_JIRA_Notification_Badge() {
  const badge = document.getElementsByClassName('css-v2uvap')[0];
  badge.parentNode.removeChild(badge);
}