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

<@common.article id="installations" title="" titleRight="174 IPT installations" class="map">
    <div id="iptmap" class="map"></div>
    <div class="right">
        <p>Located in 52 countries, serving:</p>
        <ul>
            <li>211 checklists published by 57 different publishers totaling 830 thousand usages</li>
            <li>2851 occurrence datasets published by 568 different publishers totaling 242 million records</li>
            <li>55 sampling-event datasets published by 22 different publishers totaling 12 million records</li>
            <li>374 metadata-only datasets published by 19 different publishers</li>
        </ul>
        <p><em>Status: December 2016</em></p>
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
        var
                attr = 'Nokia',
                url  = 'http://2.maps.nlp.nokia.com/maptile/2.1/maptile/newest/normal.day.grey/{z}/{x}/{y}/256/png8?app_id=_peU-uCkp-j8ovkzFGNU&app_code=gBoUkAMoxoqIWfxWA5DuMQ'
        minimal   = L.tileLayer(url, {attribution: attr})
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