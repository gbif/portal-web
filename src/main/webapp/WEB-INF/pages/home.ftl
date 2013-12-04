<html>
  <head>
    <title>GBIF Portal - Home</title>
    
     <link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.css'/>" />		
 	 <!--[if lte IE 8]><link rel="stylesheet" href="<@s.url value='/js/vendor/leaflet/leaflet.ie.css'/>" /><![endif]-->		
	 <script type="text/javascript" src="<@s.url value='/js/vendor/leaflet/leaflet.js'/>"></script>		
	 <script type="text/javascript" src="<@s.url value='/js/homepage-map.js'/>"></script>
    
    <script type="text/javascript">
		function numberWithCommas(x) {
	      return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	    }
      
      $(function() {
          $.getJSON(cfg.wsMetrics + 'occurrence/count?callback=?', function (data) {
            $("#countOccurrences").html(numberWithCommas(data));
          });
          $.getJSON(cfg.wsClbSearch + '?dataset_key=7ddf754f-d193-4cc9-b351-99906754a03b&limit=1&rank=species&status=accepted&status=DOUBTFUL&callback=?', function (data) {
            $("#countSpecies").html(numberWithCommas(data.count));
          });
          $.getJSON(cfg.wsRegSearch + '?limit=1&callback=?', function (data) {
            $("#countDatasets").html(numberWithCommas(data.count));
          });
          $.getJSON(cfg.wsReg + 'organization/count?callback=?', function (data) {
            $("#countPublishers").html(data);
          });
      });
    </script>
  </head>

  <content tag="logo_header">
  
    <div id="logo">
      <a href="<@s.url value='/'/>" class="logo"></a>
    </div>

    <div id="metrics">
      <h1>Global Biodiversity Information Facility</h1>
      <h2>Free and open access to biodiversity data</h2>

      <ul class="counters">
        <li><a href="<@s.url value='/occurrence'/>"><strong id="countOccurrences">?</strong> Occurrences</a></li>
        <li><a href="<@s.url value='/species'/>"><strong id="countSpecies">?</strong> Species</a></li>
        <li><a href="<@s.url value='/dataset'/>"><strong id="countDatasets">?</strong> Datasets</a></li>
        <li class="last"><a href="<@s.url value='/publisher/search'/>"><strong id="countPublishers">?</strong> Data publishers</a></li>
      </ul>
    </div>
  </content>

  <body class="home">
  

    <div class="container">
    
    
    

    <article class="search">

    <header>
    </header>

    <div class="content">

      <ul>
        <li>
        <h3>Enables biodiversity data sharing and re-use</h3>
        <ul>
          <li><a href="#">Why publish your data?</a></li>
          <li><a href="#">How to publish your data</a></li>
          <li><a href="#">Data from citizen scientists</a></li>
        </ul>
        </li>

        <li>
        <h3>Supports biodiversity research</h3>
        <ul>
          <li><a href="#">Why publish your data?</a></li>
          <li><a href="#">How to publish your data</a></li>
          <li><a href="#">Data from citizen scientists</a></li>
        </ul>
        </li>

        <li>
        <h3>Collaborates as a global community</h3>
        <ul>
          <li><a href="#">Why publish your data?</a></li>
          <li><a href="#">How to publish your data</a></li>
          <li><a href="#">Data from citizen scientists</a></li>
        </ul>
        </li>

      </ul>
    </div>
    <div class="footer">

      <form action="/member/search">
        <span class="input_text">
          <input type="text" name="q" placeholder="Search GBIF for species, datasets or countries" class="focus">
        </span>
        <button type="submit" class="search_button"><span>Search</span></button>
      </form>

        <div class="footer">
           <a href="#">Birds</a> &middot;
           <a href="#">Butterflies</a> &middot;
           <a href="#">Lizards</a> &middot;
           <a href="#">Reptiles</a> &middot;
           <a href="#">Fishes</a> &middot;
           <a href="#">Mammals</a> &middot;
           <a href="#">Insects</a>
         </div>
    </div>
    <footer></footer>
    </article>

</div>

</body>
</html>
