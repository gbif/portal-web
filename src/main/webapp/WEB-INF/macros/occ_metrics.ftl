<#--
A macro to create a cube metrics table that should be populated with data asynchroneously
with the help of occ_metrics.js
-->
<#macro kingdomRow kingdom usageId="" class="">
  <tr <#if usageId?has_content>data-kingdom="${usageId}"</#if> <#if class?has_content>class="${class}"</#if> >
    <td width="10%" class="title">${kingdom}</td>
    <#list ["PRESERVED_SPECIMEN", "OBSERVATION", "FOSSIL_SPECIMEN", "LIVING_SPECIMEN"] as bor>
      <td class="nonGeo" width="9%" data-bor="${bor}"><div>-</div></td>
      <td width="9%" data-bor="${bor}"><div class="geo">-</div></td>
    </#list>
    <td class="nonGeo total" width="9%" class='total'><div>-</div></td>
    <td width="9%" class='totalgeo total'><div class="geo">-</div></td>
  </tr>
</#macro>

<#macro metricsTable baseAddress>
<table class='metrics table table-bordered table-striped' data-address='${baseAddress}'>
<thead>
<tr>
<th width="10%"/>
<th colspan="2" width="9%">Specimen</th>
<th colspan="2" width="9%">Observation</th>
<th colspan="2" width="9%">Fossil</th>
<th colspan="2" width="9%">Living</th>
<th colspan="2" width="9%" class='total'>Total</th>
</tr>
<tr>
<th width="10%"/>
<th>Records</th>
<th>Georef.</th>
<th>Records</th>
<th>Georef.</th>
<th>Records</th>
<th>Georef.</th>
<th>Records</th>
<th>Georef.</th>
<th class='total'>Records</th>
<th class='total'>Georef.</th>
</tr>
</thead>
<tbody>
  <#list ["Animalia", "Archaea", "Bacteria", "Chromista", "Fungi", "Plantae", "Protozoa", "Viruses"] as k>
    <@kingdomRow kingdom=k usageId=k_index+1 />
  </#list>
  <@kingdomRow kingdom="Unknown" usageId=0 />
  <@kingdomRow kingdom="Total" class="total"/>
</tbody>
</table>
</#macro>
