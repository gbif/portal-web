<#import "/WEB-INF/macros/common.ftl" as common>
<#import "/WEB-INF/pages/developer/inc/api.ftl" as api>
<html>
<head>
    <title>IPT Stats</title>
    <link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.css'/>" />
    <!--[if lte IE 8]><link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.ie.css'/>" /><![endif]-->
    <script type="text/javascript" src="<@s.url value='/js/vendor/leaflet/leaflet.js'/>"></script>
</head>

<#assign tab="stats"/>
<#include "/WEB-INF/pages/ipt/inc/infoband.ftl" />

<body class="ipt">

<@common.article id="installations" title="" titleRight="181 IPT installations" class="map iptMap">
    <div id="iptmap" class="map"></div>
    <div class="right">
        <p>Located in 53 countries, serving:</p>
        <ul>
            <li>222 checklists published by 63 different publishers totaling 860 thousand usages</li>
            <li>3345 occurrence datasets published by 587 different publishers totaling 260 million records</li>
            <li>73 sampling-event datasets published by 25 different publishers totaling 13 million records</li>
            <li>42 metadata-only datasets published by 18 different publishers</li>
        </ul>
        <p><em>Status: March 2017</em></p>
        <h3>Don’t see your IPT?</h3>
        <p>Send <a href="mailto:helpdesk@gbif.org" title="Mail to GBIF Helpdesk requesting IPT be added to map">GBIF</a> your coordinates.</p>
    </div>
</@common.article>
    <script>
        // function gets called on each feature before adding it to the GeoJSON layer, and is used to create a popup
        function onEachFeature(feature, layer) {
            // check: does this feature have the required properties?
            if (feature.properties && feature.properties.title && feature.properties.count && feature.properties.key) {
                // create link to publisher page displaying publisher title in popup
                var ln = '<a href="'+"/publisher/"+ feature.properties.key+'">'+feature.properties.title+'</a>';
                // determine if it should say installation, or installations plural
                var i = "installations";
                if (feature.properties.count == "1") {
                    i = "installation";
                }
                // bind popup to feature
                layer.bindPopup("<p>" + ln + "<br>" + feature.properties.count + " " + i + "</p>");
            }
        }
        var attr = '© OpenMapTiles © OpenStreetMap contributors';
	var url = 'https://tile.gbif.org/3857/omt/{z}/{x}/{y}@1x.png?style=osm-bright';
        var minimal   = L.tileLayer(url, {attribution: attr, tileSize: 512, zoomOffset: -1})
        var map = L.map('iptmap', {
            center: [30,0],
            zoom: 1,
            layers: [minimal],
            zoomControl: true
        });
        $.getJSON(cfg.wsReg + "installation/location/IPT_INSTALLATION", function(data){
            L.geoJson(data, {onEachFeature: onEachFeature}).addTo(map);
        });

    </script>
</body>
</html>
