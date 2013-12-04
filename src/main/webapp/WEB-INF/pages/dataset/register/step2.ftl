<html>
<head>
  <title>Dataset registration (2/3) - GBIF</title>

  <content tag="extra_scripts">
    <script type="text/javascript">
    $(function() {
      $(".data_policy").selectBox();
      $(".select").selectBox();

      // Autocomplete for the publisher name field
      publishers = [
        { name: "Publisher 1", desc: "Description"},
        { name: "Publisher 2", desc: "Description"},
        { name: "Publisher 3", desc: "Description"},
        { name: "Publisher 4", desc: "Description"}
      ],
      $("#publisher_name").autocomplete(publishers, {
        minChars: 0, scroll:false, width: 225, matchContains: "word", autoFill: false, max:3,
        formatItem: function(row, i, max) {
          var clase = "";

          // Classes to choose the right background for the row
          if (max == 1) {
            clase = ' unique';
          } else if (max == 2 && i == 2) {
            clase = ' last_double';
          } else if (i == 1) {
            clase = ' first';
          } else if (i == max) {
            clase = ' last';
          }
          return '<div class="row' + clase + '"><span class="name">' + row.name + '</span>' + row.desc +
                 '</div>';
        },
        formatResult: function(row) {
          return row.name;
        }
      });
    });
    </script>
  </content>
</head>
<body class="infobandless">

  <article id="step-1" class="tunnel">
    <header></header>
    <div class="content">
      <ul class="breadcrumb">
        <li><h2>Share your data in GBIF</h2></li>
        <li class="active"><h2>Register your dataset</h2></li>
        <li class="last"><h2>Finish</h2></li>
      </ul>

      <p>Once you have the data publishing software installed, we just need to ask you for three simple things:</p>

      <div class="important">
        <div class="top"></div>
        <div class="inner">
          <img src="<@s.url value='/img/icons/computer_plug.png'/>" class="icon"/>

          <form>

            <div class="field">
              <p>Provide us your dataset's access point URL. <a href="#" title="Help" id="help" class="help">
                <img src="<@s.url value='/img/icons/questionmark.png'/>"/></a></p>
              <input type="text" name="text"/>
              <button type="submit" class="button"><span>Connect</span></button>
            </div>

            <div class="field">
              <p>Data publisher name <a href="#" title="Help" id="help2" class="help"><img src="<@s.url value='/img/icons/questionmark.png'/>"/></a></p>
          <span class="input_text">
            <input id="publisher_name" name="publisher_name" type="text"/>
          </span>
            </div>


            <div class="field">
              <p>GBIF endorsing node <a href="#" title="Help" id="help3" class="help">
                <img src="<@s.url value='/img/icons/questionmark.png'/>"/></a></p>
              <select id="endorsing_node" class="endorsing_node" name="endorsing_node">
                <option value="">Select one of the list below...</option>
                <option value="endorsing_node-1">ACB</option>
                <option value="endorsing_node-2">Andorra</option>
                <option value="endorsing_node-3">Austria</option>
                <option value="endorsing_node-4">Argentina</option>
              </select>
            </div>
          </form>
        </div>
        <div class="bottom"></div>
      </div>

      <nav><a href="<@s.url value='/dataset/register/step3'/>" title="Finish" class="candy_white_button next"><span>Finish</span></a>

        <p>Clicking on "Finish" you are accepting the GBIF Data Sharing Agreement
          <a href="<@s.url value='/about/sharing'/>" title="Terms &amp; Conditions">Terms &amp; Conditions</a></p></nav>
    </div>
    <footer></footer>
  </article>

</body>
</html>
