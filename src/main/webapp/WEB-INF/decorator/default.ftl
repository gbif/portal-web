<!doctype html>
<#setting url_escaping_charset="UTF-8">
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7 ]> <html class="no-js ie6" lang="en"> <![endif]-->
<!--[if IE 7 ]>    <html class="no-js ie7" lang="en"> <![endif]-->
<!--[if IE 8 ]>    <html class="no-js ie8" lang="en"> <![endif]-->
<!--[if IE 9 ]>    <html class="ie9"> <![endif]-->
<!--[if (gte IE 9)|!(IE)]><!-->
<!--
    __________  __________   ____        __           ____             __        __
   / ____/ __ )/  _/ ____/  / __ \____ _/ /_____ _   / __ \____  _____/ /_____ _/ /
  / / __/ __  |/ // /_     / / / / __ `/ __/ __ `/  / /_/ / __ \/ ___/ __/ __ `/ /
 / /_/ / /_/ // // __/    / /_/ / /_/ / /_/ /_/ /  / ____/ /_/ / /  / /_/ /_/ / /
 \____/_____/___/_/      /_____/\__,_/\__/\__,_/  /_/    \____/_/   \__/\__,_/_/
-->
<#-- no-js comes from modernizer: http://alistapart.com/article/taking-advantage-of-html5-and-css3-with-modernizr -->
<html class="no-js" lang="en" xmlns="http://www.w3.org/1999/xhtml">
<!--<![endif]-->
<head>
  <meta charset="utf-8">
  <#-- Load bundle properties. The action class can filter out which properties to show according to their key's prefixes -->
  <#if resourceBundleProperties?has_content>
  <script id="resources" type="text/plain">
    <#list resourceBundleProperties?keys as property>
    ${property}=${resourceBundleProperties.get(property)}
    </#list>
  </script>
  </#if>
  <#-- Always force latest IE rendering engine (even in intranet) & Chrome Frame Remove this if you use the .htaccess -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title property="dc:title">${title}</title>
  <meta name="description" content="">
  <meta name="author" content="GBIF">
  <#-- Mobile viewport optimized: j.mp/bplateviewport -->
  <!--
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  -->
  <link rel="shortcut icon" href="<@s.url value='/img/favicon/favicon_32x32.ico'/>">
  <#-- Replace apple-touch-icon.png as per issue http://dev.gbif.org/issues/browse/POR-403 Without a proper path Struts2 configuration exception is thrown-->
  <link rel="apple-touch-icon" href="<@s.url value='/img/favicon/favicon_32x32.ico'/>">
  <#-- CSS: implied media="all" -->
  <link rel="stylesheet" href="<@s.url value='/css/style.css?v=2'/>"/>
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/themes/base/jquery-ui.css" type="text/css" media="all"/>
  <link rel="stylesheet" type="text/css" media="print" href="<@s.url value='/css/print.css'/>">

  <script src="<@s.url value='/cfg'/>"></script>
  <script src="<@s.url value='/js/vendor/modernizr-1.7.min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-1.7.1.min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/jquery.cookie.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/menu.js'/>"></script>
  <!-- we have issues with firefox, not only IE: http://dev.gbif.org/issues/browse/POR-412 -->
  <script type="text/javascript" src="<@s.url value='/js/vendor/css_browser_selector.js'/>"></script>

  ${head}

</head>
<body class="${page.properties["body.class"]!}">

  <header>
  <!-- To most pages this will be ignored-->
  <div id="homepageMap"></div>


  <!-- top -->
  <div id="top">
    <div class="content">



      <div class="account">
        <#if currentUser??>
        <a href="${cfg.drupal}/user/${currentUser.key}/edit" title='Account'>Hello ${currentUser.firstName!currentUser.accountName!}</a>
        or
        <a href="${cfg.drupal}/user/logout?destination=${currentDestinationParam?url}" title='<@s.text name="menu.logout"/>'><@s.text name="menu.logout"/></a>
        <#else>
        <a href="${cfg.drupal}/user/login?destination=${currentDestinationParam?url}" title='<@s.text name="menu.login"/>'><@s.text name="menu.login"/></a> or
        <a href="${cfg.drupal}/user/register" title='<@s.text name="menu.register"/>'><@s.text name="menu.register"/></a>
        </#if>
      </div>

    <#if page.properties["page.logo_header"]?has_content>
      ${page.properties["page.logo_header"]}
    <#else>
      <div id="logo">
        <a href="${cfg.drupal}/" class="logo"><img src="<@s.url value='/img/header/logo.png'/>" alt="GBIF"/></a>

        <h1><a href="${cfg.drupal}/" title="GBIF.ORG">GBIF.ORG</a></h1>
        <span>Free and open access to biodiversity data</span>
      </div>
    </#if>
    
    <nav>

      <ul>
        <li>
          <a href="#" title="Data">Data</a>
          <div class="data">
            <a href="#"></a>
            <ul>
              <li><a href="<@s.url value='/occurrence'/>"><@s.text name="menu.occurrence"/></a></li>
              <li><a href="<@s.url value='/dataset'/>"><@s.text name="menu.dataset"/></a></li>
              <li><a href="<@s.url value='/species'/>"><@s.text name="menu.species"/></a></li>
              <li><a href="<@s.url value='/country'/>"><@s.text name="menu.country"/></a></li>
              <li class="divider"></li>
              <li><a href="${cfg.drupal}/publishingdata/summary">Publishing data</a></li>
              <li><a href="${cfg.drupal}/usingdata/summary">Using data</a></li>
              <li><a href="<@s.url value='/infrastructure/summary'/>">Infrastructure</a></li>
            </ul>
          </div>
        </li>

          <li>
          <a href="#" title="About GBIF">News</a>

          <div class="news">
            <a href="#"></a>
            <ul>
              <li><a href="${cfg.drupal}/newsroom/summary">GBIF news</a></li>
              <li><a href="${cfg.drupal}/newsroom/uses">Featured data use</a></li>
              <li><a href="${cfg.drupal}/newsroom/opportunities">Opportunities</a></li>
              <li><a href="${cfg.drupal}/newsroom/events">Events</a></li>
            </ul>
          </div>

          </li>

       <li>
          <a href="#" title="Community">Community</a>
          <div class="community">
            <a href="#"></a>
            <ul>
                <li><a href="${cfg.drupal}/participation/summary">Participation</a></li>
                <li><a href="${cfg.drupal}/capacityenhancement/summary">Capacity enhancement</a></li>
                <li><a href="${cfg.drupal}/resources/summary">Resources</a></li>
            </ul>
          </div>
        </li>

          <li>
            <a href="#" title="About GBIF">About</a>
            <div class="about">
              <a href="#"></a>
              <ul>
                <li><a href="${cfg.drupal}/whatisgbif">What is GBIF?</a></li>
                <li><a href="${cfg.drupal}/resources/keyinformation">Key information</a></li>
                <li><a href="${cfg.drupal}/governance/governingboard">Governance</a></li>
                <li><a href="${cfg.drupal}/whoweworkwith">Who we work with</a></li>
                <li><a href="${cfg.drupal}/contact/contactus">Contact us</a></li>
              </ul>
            </div>
          </li>


        <li class="search">
        <form action="${cfg.drupal}/search/node" method="GET">
          <span class="input_text">
              <!-- Global search disabled until implemented later. See issue: http://dev.gbif.org/issues/browse/POR-387 -->
            <input type="text" name="keys" />
          </span>
        </form>
        </li>
      </ul>

    </nav>
    </div>
  </div>
  <!-- /top -->


  <#if page.properties["page.infoband"]?has_content>
  <div id="infoband">
    <div class="content">
      ${page.properties["page.infoband"]}
    </div>
  </div>
  </#if>

  <#if page.properties["page.tabs"]?has_content>
  <div id="tabs">
    <div class="content">
      ${page.properties["page.tabs"]}
    </div>
  </div>
  </#if>

  </header>


  <div id="content">

    ${body}

  </div>

  <footer>
    <div id="link_footer">
      <div class="footer">
        <ul>
            <li><h3>JOIN THE COMMUNITY</h3></li>
            <li><a href="http://community.gbif.org/">Join GBIF Community Site</a></li>
            <li><a href="${cfg.drupal}/newsroom/summary/#signup">Sign up to GBits newsletter</a></li>
            <li><a href="${cfg.drupal}/resources/summary">GBIF Online Resource Centre</a></li>
        </ul>

        <ul>
            <li><h3>WHO’S PARTICIPATING</h3></li>
            <li><a href="<@s.url value='/participation/list#voting'/>">Countries</a></li>
            <li><a href="<@s.url value='/participation/list#other'/>">Organizations</a></li>
            <li><a href="<@s.url value='/publisher/search'/>">Data publishers</a></li>
        </ul>

        <ul>
            <li><h3>KEY DOCUMENTS</h3></li>
            <li><a href="${cfg.drupal}/disclaimer">Disclaimer</a></li>
            <li><a href="${cfg.drupal}/disclaimer/datause">Data use agreement</a></li>
            <li><a href="${cfg.drupal}/disclaimer/datasharing">Data sharing agreement</a></li>
            <li><a href="http://www.gbif.org/resources/2605">Memorandum of Understanding</a></li>
            <li><a href="http://www.gbif.org/resources/2262">Annual Report</a></li>
            <li><a href="http://www.gbif.org/resources/2569">GBIF Strategic Plan</a></li>
            <li><a href="http://www.gbif.org/resources/2970">GBIF Work Programme</a></li>
        </ul>

        <ul class="last">
            <li><h3>FOR DEVELOPERS</h3></li>
            <li><a href="<@s.url value='/developer'/>">Portal API</a></li>
            <li><a href="http://gbif.blogspot.com">Developer blog</a></li>
            <li><a href="<@s.url value='/infrastructure/tools'/>">Tools</a></li>
          <#--
            http://dev.gbif.org/issues/browse/PF-1110
            <li><a href="#">Standards</a></li>
            -->
        </ul>

      </div>
    </div>
    <div id="contact_footer">
      <div class="footer">
          <ul>
              <li><h3>2013 &copy; GBIF</h3></li>
              <li><div class="logo"></div></li>
          </ul>

          <ul>
              <li><h3>GBIF Secretariat</h3></li>
              <li>Universitetsparken 15</li>
              <li>DK-2100 Copenhagen Ø</li>
              <li>DENMARK</li>
          </ul>

          <ul>
            <li><h3>Contact</h3></li>
            <li><strong>Email</strong> info@gbif.org</li>
            <li><strong>Tel</strong> +45 35 32 14 70</li>
            <li><strong>Fax</strong> +45 35 32 14 80</li>
            <li>You can also check the <a href="${cfg.drupal}/contact/directoryofcontacts#secretariat">GBIF Directory</a></li>
          </ul>

          <ul class="social last">
              <li><h3>SOCIAL MEDIA</h3></li>
              <li class="twitter"><i></i><a href="https://twitter.com/GBIF">Follow GBIF on Twitter</a></li>
              <li class="facebook"><i></i><a href="https://www.facebook.com/gbifnews">Like GBIF on Facebook</a></li>
              <li class="linkedin"><i></i><a href="http://www.linkedin.com/groups/GBIF-55171">Join GBIF on Linkedin</a></li>
              <li class="vimeo"><i></i><a href="http://vimeo.com/gbif">View GBIF on Vimeo</a></li>
          </ul>

        </div>
    </div>
  </footer>

  <!-- JavaScript at the bottom for fast page loading -->
  <!-- scripts concatenated and minified via ant build script  -->
  <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-ui-1.8.17.min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/jquery.dropkick-1.0.0.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/jquery.uniform.min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/mousewheel.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/jscrollpane.min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-scrollTo-1.4.2-min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/bootstrap.min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/underscore-min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/helpers.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/widgets.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/graphs.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/app.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/raphael-min.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/resourcebundle.js'/>"></script>
  <script type="text/javascript" src="<@s.url value='/js/vendor/moment.min.js'/>"></script>
  <#-- JIRA feedback buttons -->
  <script type="text/javascript" src="http://dev.gbif.org/issues/s/en_UKkby86d-1988229788/6096/5/1.4.0-m2/_/download/batch/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector.js?collectorId=a2e9eca4"></script>
  <#-- Google analytics -->
  <#if cfg.googleAnalytics?has_content>
  <script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', '${cfg.googleAnalytics}', 'gbif.org');
    ga('send', 'pageview');
  </script>
  </#if>
  <!-- end scripts-->

  <!--[if lt IE 7 ]>
  <script src="<@s.url value='/js/libs/dd_belatedpng.js'/>"></script>
  <script>DD_belatedPNG.fix("img, .png_bg"); // Fix any <img> or .png_bg bg-images. Also, please read goo.gl/mZiyb </script>
  <![endif]-->

  <#if page.properties["page.extra_scripts"]?has_content>
  ${page.properties["page.extra_scripts"]}
  </#if>

</body>
</html>
