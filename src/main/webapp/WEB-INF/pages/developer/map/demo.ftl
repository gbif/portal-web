<#import "/WEB-INF/macros/common.ftl" as common>
<html>
  <head>
    <title>Map demo</title>
    <content tag="extra_scripts">
      <script>
    
        // we capture events from the iframes, to control the links to the occurrence search
        function receiveMessage(event) {
          if (event.data.searchUrl !== undefined) {
            $("#" + event.data.origin + "-link").attr("href", "<@s.url value='/occurrence/search'/>?" +  event.data.searchUrl);
          }
        }
        
        if (window.addEventListener){
          window.addEventListener("message", receiveMessage, false);
        } else if (window.attachEvent){ // IE 
          window.attachEvent('onmessage', receiveMessage);
        }             
      </script>    
    </content>
  </head>

  <body class="search">
    <content tag="infoband">
      <h1>Mapping demonstrations</h1>
      <h3>Intended for developers to understand how to embed the map widget in pages</h3>
    </content>
    
    
	<a name="densityTile"></a>
    <article class="map">
      <header></header>
      <div class="content">
        <div class="header">
          <div class="right">
            <h2>Georeferenced data</h2>
          </div>
        </div>
        <div class="map">
          <iframe id="map1" name="map1" 
            src="${cfg.tileServerBaseUrl!}/index.html?type=TAXON&key=1&layertype=png" 
            allowfullscreen height="423" width="627" frameborder="0" />
          </iframe>
        </div>
        <div class="right">
          <div class="inner">
            <h3>View records</h3>
            <p>
              <a href="<@s.url value='/occurrence/search'/>?taxon_key=1&amp;BOUNDING_BOX=90%2C-180%2C-90%2C180">Georeferenced</a>
              |
              <#-- The iframe callback will modify this on widget change -->
              <a id="map1-link" href="/occurrence/search?taxon_key=1">In viewable area</a>
            </p>
          </div>
        </div>
      </div>
      <footer></footer>
    </article>
    
    
</html>
