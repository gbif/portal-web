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
          <table>
            <tr>
              <td style="width: 150px;">
                <input type="radio" name="downloadFormat" value="SIMPLE_CSV" checked/> Simple CSV
              </td>
              <td>
                <div><p id="SIMPLE_CSV_description" class="download_format_description">The simple CSV format provides a tabular view of the data with the most commonly used columns. The table includes only the data after it has gone through interpretation and quality control. Tools such as Microsoft Excel can be used to read this format.</p></div>
              </td>
            </tr>
            <tr>
              <td style="width: 150px;">
                <input type="radio" name="downloadFormat" value="DWCA"/> Darwin Core Archive
              </td>
              <td>
                <div>
              <p id="DWCA_description" class="download_format_description">The Darwin Core Archive format is a TDWG Standard and contains rich information. It is a zip file containing the original data as shared by the publisher, and the interpreted view after data has gone through quality control procedures. Additional files provide supplementary information such as images. This is a richer format than simple CSV but provides the most complete view of data.</p></div>
              </td>
            </tr>
           </table>
        </div>
      </div>
      <div class="downloadpopup_section">
        <h3>Notifications</h3>
        <div id="notifications">
          <a href="#">Notify others of results?</a>
          <div id="emails_div">
            Press 'Enter' to add an email addresses<br>
            <ul id="emails"></ul>
            <input type="hidden" name="notify_others" id="notify_others"/>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="lfooter">
    <a href="#" class="candy_blue_button download_submit_button" style="width: 100px; margin:4px auto;"><span>Download</span></a>
  </div>
</div>
