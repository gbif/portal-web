<!--Download popup: shows the functionality to select the download format and add additional notifycation emails-->
<div id="downloadpopup" class="infowindow dialogPopover downloadpopup" style="display: none;">
  <div class="lheader"></div>
  <span class="close"></span>
  <div class="content">
    <h2>Occurrence download</h2>
    <div class="scrollpane">
      <br>
      <div class="downloadpopup_section">
        <h3>Download format</h3>
        <div>
          <select id="downloadFormat" name="downloadFormat" class="dropkick_class">
            <option value="DWCA">DwCA</option>
            <option value="SIMPLE_CSV">CSV</option>
          </select>
          <div>
            <p id="DWCA_description" class="download_format_description" style="display: block;">Darwin Core Archive file that is a zip of all indexed fields in both verbatim and interpreted, plus multimedia and metadata files.</p>
            <p id="SIMPLE_CSV_description" class="download_format_description" style="display: none;">Zipped text file of the most common indexed terms, but note that it is delimited by tabs, not commas.</p>
          </div>
        </div>
      </div>
      <div class="downloadpopup_section">
        <h3>Notifications</h3>
        <div id="notifications">
          <a href="#">Notify others of results?</a>
          <div id="emails_div">
            Press 'Enter' to add an email addresses<br>
            <ul id="emails"></ul>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="lfooter">
    <a href="#" class="candy_blue_button download_submit_button" style="width: 100px; margin:4px auto;"><span>Download</span></a>
  </div>
</div>
