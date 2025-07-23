<#if social.providers?? && social.providers?size == 1>
  <#assign p = social.providers[0]>
  <meta http-equiv="refresh" content="0; url=${p.loginUrl}">
<#else>
  <#import "template.ftl" as layout>
  <@layout.registrationLayout displayInfo=false displayMessage=true; section>
    <div id="kc-social-providers">
      <#list social.providers as p>
        <a id="social-${p.alias}" class="social-link" type="${p.alias}"
           href="${p.loginUrl}" title="${p.displayName}">
          <span class="social-icon fa fa-${p.alias}"></span>
          Sign in with ${p.displayName}
        </a>
      </#list>
    </div>
  </@layout.registrationLayout>
</#if>
