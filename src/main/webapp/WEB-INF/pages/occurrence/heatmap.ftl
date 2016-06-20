<#import "/WEB-INF/macros/common.ftl" as common>
<html>
  <head>
    <title>Occurrence Heatmaps</title>

    <content tag="extra_scripts">

    <script src='<@s.url value='/js/vendor/jquery.url.js'/>' type='text/javascript'></script>
    <script type="text/javascript" src="<@s.url value='/js/vendor/jquery-ui-1.8.17.min.js'/>"></script>
    <script>
      $(function() {
        var mapURL = '${cfg.tileServerBaseUrl!}/heatmap.html?&resolution=1&x={x}&y={y}&z={z}&palette=yellows_reds&' +
                     window.location.href.slice(window.location.href.indexOf('?') + 1);

        var mapframe = $('#mapframe');
        mapframe.attr('src', mapURL);
      });
    </script>
    </content>
  </head>
  <body class="infobandless">


  <div id="map" style="width: 650px !important; height: 550px !important; clear: both; margin: 0 auto; overflow: hidden !important;">
      <iframe id="mapframe" name="mapframe" src="" allowfullscreen height="100%" width="100%" frameborder="0" scrolling="no"/></iframe>
  </div>

</body>
</html>
