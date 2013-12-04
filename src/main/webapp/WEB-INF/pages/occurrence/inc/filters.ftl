  <#import "/WEB-INF/macros/common.ftl" as common>
  <!-- Filter templates -->
  <script type="text/template" id="template-month-filter">
    <tr class="filter">
      <td colspan="4">
        <a class="edit" style="display:none;"/>
        <div class="inner filter_view">
          <h4 class="title"><%= title %></h4>                    
          <div class="filter">                                         
            <table>              
              <tr>
                <td style="border: 0px none !important;">                  
                   <div class="date-filter">
                    <table>   
                     <tr>
                      <td>                 
                        <select name="predicate" class="predicate">
                          <option value="eq">Is</option>
                          <option value="lte">Is before</option>
                          <option value="gte">Is after</option>
                          <option value="bt">Between</option>                                            
                        </select>
                      </td>
                      <td>  
                        <select name="monthMin" class="date-dropdown">
                          <option value="0">-</option>
                          <option value="1">January</option>
                          <option value="2">February</option>
                          <option value="3">March</option>
                          <option value="4">April</option>
                          <option value="5">May</option>
                          <option value="6">June</option>
                          <option value="7">July</option>
                          <option value="8">August</option>
                          <option value="9">September</option>
                          <option value="10">October</option>
                          <option value="11">November</option>
                          <option value="12">December</option>
                        </select>                                                      
                                            
                        <div id="maxValue" style="display:none">          
                          <select name="monthMax" class="date-dropdown">
                            <option value="0">-</option>
                            <option value="1">January</option>
                            <option value="2">February</option>
                            <option value="3">March</option>
                            <option value="4">April</option>
                            <option value="5">May</option>
                            <option value="6">June</option>
                            <option value="7">July</option>
                            <option value="8">August</option>
                            <option value="9">September</option>
                            <option value="10">October</option>
                            <option value="11">November</option>
                            <option value="12">December</option>
                          </div>
                        </span>
                      </td>
                      <td>
                        <input type="image" src="<@s.url value='/img/admin/add-small.png'/>" class="addFilter"/>
                      </td> 
                    </tr>
                  </table>      
                </div>                
                <span style="display: none;" id="monthRangeErrorMessage" class="warningBox month_error">
                    <p>Invalid range of months has been specified, second month must be greater than the first one</p>
                </span>
                </td>
                <td style="border: 0px none !important;">
                  <h4 class="filtersTitle" style="display:none;">Filters</h4>
                  <div class="appliedFilters filterlist" style="display:none;"></div>
                </td>                           
              </tr>
            </table>                         
            <a class="button candy_blue_button apply" title="<%= title %>" data-action="add-month-filter" data-filter="<%= paramName %>" apply-function="applyOccurrenceFilters"><span>Apply</span></a>
          </div>          
          <a class="close"></a>
        </div>
        <div class="summary_view">          
          
        </div>
      </td>
    </tr>
  </script>
  
  
  <script type="text/template" id="template-basis-of-record-filter">
    <tr class="filter">
      <td colspan="4">
        <a class="edit" style="display:none;"/>
        <div class="inner filter_view">
          <h4 class="title"><%= title %></h4>
          <div class="filter">
            <h4 class="title">Select </h4>
            <ul class="basis-of-record">
              <#list basisOfRecords as basisOfRecord>         
                <li key="${basisOfRecord}"><a>${action.getFilterTitle('basisOfRecord',basisOfRecord)}</a></li>         
              </#list>
            </ul>            
          </div>
          <div class="center">
            <a class="button candy_blue_button apply" title="<%= title %>" data-action="add-new-filter" data-filter="<%= paramName %>" apply-function="applyOccurrenceFilters"><span>Apply</span></a>
          </div>
          <a class="close"></a>
        </div>
        <div class="summary_view">          
          
        </div>
      </td>
    </tr>
  </script>
  
  <script type="text/template" id="template-add-filter">
    <tr class="filter">
      <td colspan="4">
        <a class="edit" style="display:none;"/>
        <div class="inner filter_view">
          <h4 class="title"><%= title %></h4>
          <div class="filter">
            <table>                
                <tr> 
                  <td>
                    <h4>&nbsp;</h4>                    
                    <input type="text" name="<%=paramName%>" class="<%= inputClasses %>" placeholder="<%= placeholder %>" />
                    <input type="image" src="<@s.url value='/img/admin/add-small.png'/>" class="addFilter"/>
                    <span style="display:none" class="erroMsg">Please enter a value</span>
                  </td>
                  <td>
                    <h4 class="filtersTitle" style="display:none;">Filters</h4>
                    <div class="appliedFilters filterlist" style="display:none;"></div>
                  </td>                  
                </tr>
             </table>                        
          </div>
          <div class="center">
            <a class="button candy_blue_button apply" title="<%= title %>" data-action="add-new-filter" data-filter="<%= paramName %>" apply-function="applyOccurrenceFilters"><span>Apply</span></a>
          </div>
          <a class="close"></a>
        </div>
        <div class="summary_view">          
          
        </div>
      </td>
    </tr>
  </script>
  
  
   <script type="text/template" id="template-simple-filter">
    <tr class="filter">
      <td colspan="4">
        <a class="edit" style="display:none;"/>  
        <div class="inner filter_view">
          <h4 class="title"><%= title %></h4>
          <div class="filter">
            <table>                
                <tr> 
                  <td>       
                    <h4>&nbsp;</h4>             
                    <input type="text" name="<%=paramName%>" class="<%= inputClasses %>" placeholder="<%= placeholder %>" />                    
                  </td>
                  <td>
                    <h4 class="filtersTitle" style="display:none;">Filters</h4>
                    <div class="appliedFilters filterlist" style="display:none;"></div>
                  </td>                  
                </tr>
             </table>                        
          </div>
          <div class="center">
            <a class="button candy_blue_button apply" title="<%= title %>" data-action="add-new-filter" data-filter="<%= paramName %>" apply-function="applyOccurrenceFilters"><span>Apply</span></a>
          </div>
          <a class="close"></a>
        </div>
        <div class="summary_view"></div>                
      </td>
    </tr>
  </script>
  
  <script type="text/template" id="template-compare-filter">
    <tr class="filter">
      <td colspan="4">
        <a class="edit" style="display:none;"/>
        <div class="inner filter_view">
          <h4 class="title"><%= title %></h4>
          <div class="filter">
            <table>                
                <tr> 
                  <td>  
                    <h4>&nbsp;</h4>                                                                
                    <select name="predicate" class="predicate">
                      <option value="eq">Is</option>
                      <% if (inputClasses.indexOf("temporal") == -1){%>                        
                        <option value="gte">Is greater than</option>
                        <option value="lte">Is less than</option>                        
                      <%} else {%>
                        <option value="lte">Is before</option>                        
                        <option value="gte">Is after</option>
                      <%}%>                                  
                      <option value="bt">Between</option>          
                    </select>
                    <input type="text" size="17" maxlength="15" name="<%=paramName%>" class="form-control <%= inputClasses %>" placeholder="<%= placeholder %>" style="width:130px;"/>
                    <span style="display:none" class="erroMsg">Please enter a value</span>                 
                    <span id="maxValue" style="display:none">
                      <span>and</span> 
                      <input type="text" size="17"  maxlength="15" name="<%=paramName%>Max" class="form-control <%= inputClasses %>" placeholder="<%= placeholder %>" style="width:130px;"/>
                    </span>   
                    <input type="image" src="<@s.url value='/img/admin/add-small.png'/>" class="addFilter">                    
                  </td>
                  <td>
                    <h4 class="filtersTitle" style="display:none;">Filters</h4>
                    <div class="appliedFilters filterlist" style="display:none;"></div>
                  </td>                  
                </tr>
             </table>                        
          </div>
          <div class="center">
            <a class="button candy_blue_button apply" title="<%= title %>" data-action="add-new-filter" data-filter="<%= paramName %>" apply-function="applyOccurrenceFilters"><span>Apply</span></a>
          </div>
          <a class="close"></a>
        </div>
        <div class="summary_view">          
          
        </div> 
      </td>      
    </tr>
  </script>
  
  
  <script type="text/template" id="template-date-compare-filter">
    <tr class="filter">
      <td colspan="4">
        <a class="edit" style="display:none;"/>        
        <div class="inner filter_view">
            <h4 class="title"><%= title %><img class="configure_dates" src="<@s.url value='/img/icons/cog_gray_small.png'/>"></h4>            
            <div class="filter">                      
            <table style="border:none !important;">    
                <tr class="date_fmt_cfg" style="display:none;">
                  <td>
                    <div class="configure_dates_box" style="display:inline-block !important;">        
                      <img class="configure_dates close_cfg" src="<@s.url value='/img/icons/filter_close.png'/>"></br>                                         
                      <table> 
                        <tr>
                          <td>
                          <span class="label">Search by</span>        
                          <select name="formatDateFrom" data-target="dateFrom" class="date_format">                  
                            <option value="months">Year and month</option>
                            <option value="days">Full date</option>
                            <option value="years">Year</option>
                          </select>
                          </td>
                          <td>
                          <span class="max_value_cfg">
                            <span class="label">and by</span>
                            <select name="formatDateTo" data-target="dateTo" class="date_format">                  
                              <option value="months">Year and month</option>
                              <option value="days">Full date</option>
                              <option value="years">Year</option>
                            </select>
                          </span>
                          </td>
                        </tr>       
                      </table>
                    </div>
                  </td>
                </tr>            
                <tr> 
                  <td>                                                     
                    <select name="predicate" class="predicate">                      
                      <option value="eq">Is</option>                      
                      <option value="lte">Is before</option>                        
                      <option value="gte">Is after</option>
                      <option value="bt">Between</option>
                    </select>     
                    <input type="text" size="17" maxlength="15" name="<%=paramName%>" class="min_value <%= inputClasses %>" placeholder="<%= placeholder %>" style="width:90px;"/>                    
                    <span style="display:none" class="erroMsg">Please enter a value</span>                 
                    <span id="maxValue" style="display:none" class="max_value_cfg">
                      <span>and</span>                                             
                        <input type="text" size="17"  maxlength="15" name="<%=paramName%>Max" class="max_value <%= inputClasses %>" placeholder="<%= placeholder %>" style="width:90px;"/>                      
                    </span>                       
                    <input type="image" src="<@s.url value='/img/admin/add-small.png'/>" class="addFilter">                    
                  </td>
                  <td>
                    <h4 class="filtersTitle" style="display:none;">Filters</h4>
                    <div class="appliedFilters filterlist" style="display:none;"></div>
                  </td>                  
                </tr>
             </table>                        
          </div>
          <div class="center">
            <a class="button candy_blue_button apply" title="<%= title %>" data-action="add-new-filter" data-filter="<%= paramName %>" apply-function="applyOccurrenceFilters"><span>Apply</span></a>
          </div>
          <a class="close"></a>
        </div>
        <div class="summary_view">          
          
        </div> 
      </td>      
    </tr>
  </script>

  <script type="text/template" id="template-filter">
    <ul>
    <li id="filter-<%=paramName%>">
    <div style="display:inline-block"><h4><%= title %></h4></div>
    <% _.each(filters, function(filter) { %>
        <div class="filter"><div class="filter_content"><%= filter.label %><input name="<%= filter.paramName %>" type="hidden" key="<%= filter.key %>" value="<%= filter.value %>"/><a class="closeFilter"></a></div></div>        
      <% }); %>                  
    </li>
    </ul>
  </script>
  
  <script type="text/template" id="template-summary-location">
    <ul>
    <li id="filter-<%=paramName%>">
    <div style="display:inline-block"><h4>Location</h4></div>
    <% _.each(filters, function(filter) { %>
        <div class="filter"><div class="filter_content">
           <%if (typeof(filter.targetParam) != "undefined" && filter.targetParam == 'POLYGON' ) {%><img src="../js/vendor/leaflet/draw/images/draw-polygon.png"/><%= filter.label.replace("POLYGON((","").replace("))","") %>
           <%} else if (typeof(filter.targetParam) != "undefined" && filter.targetParam == 'BOUNDING_BOX' ) {%>
            <img src="../js/vendor/leaflet/draw/images/draw-rectangle.png"/><%}%><%= filter.label %><input name="<%= filter.paramName %>" type="hidden" key="<%= filter.key %>" value="<%= filter.value %>"/><a class="closeFilter"></a></div></div>        
      <% }); %>                  
    </li>
    </ul>
  </script>
  
  
  <script type="text/template" id="DATASET_KEY-suggestions-template">
    <#list datasetsSuggestions.replacements?keys as title>   
      <#assign suggestion = datasetSuggestions.replacements[title]>         
      <div class="suggestionBox" data-replacement="${title}">         
        <div class="warningBox"> <span class="warningCounter">!</span> The dataset name <strong>"${title}"</strong> was replaced by: <br>            
          ${suggestion.title}                             
        </div>                               
      </div>               
     </#list>         
    <#list datasetsSuggestions.suggestions?keys as title>            
      <div class="suggestionBox" data-suggestion="${title}">         
       <#assign suggestions = datasetsSuggestions.suggestions[title]>
         <#if suggestions?has_content>
          <div class="warningBox"> <span class="warningCounter">!</span> We found more than one dataset that matched <strong>"${title}"</strong>.Please select a dataset from the list below.</div>                               
          <#list suggestions as datasetSearchResult>
              <input id="searchResult${datasetSearchResult.key}" type="radio" value="${datasetSearchResult.key}" name="DATASET_KEY" class="suggestion" data-suggestion="${title}"/>
              <label for="searchResult${datasetSearchResult.key}">${datasetSearchResult.title}
              <#if datasetSearchResult.owningOrganizationTitle?has_content>                 
                (Published by  <em>${datasetSearchResult.owningOrganizationTitle} </em>)
              <#elseif datasetSearchResult.networkOfOriginKey?has_content>
                (Originates from <em>${action.getNetworkTitle(datasetSearchResult.networkOfOriginKey)!"Unknown"}</em>)
              </#if>                
              </label>                
              </br>                                                    
          </#list>
         <#else>
           <div class="warningBox"> <span class="warningCounter">${title_index + 1}</span> We haven't found any dataset name that matched <strong>"${title}"</strong>.</div>
         </#if>                  
      </div>               
     </#list>
  </script>
  
  
  <script type="text/template" id="suggestions-template-filter">
    <ul>
    <li id="filter-<%=paramName%>">
    <div style="display:inline-block"><h4><%= title %></h4></div>
    <% _.each(filters, function(filter) { %>
        <div class="filter"><div class="filter_content"><%= filter.label %><input name="<%= filter.paramName %>" type="hidden" key="<%= filter.key %>" value="<%= filter.value %>"/><a class="closeFilter"></a></div></div>         
      <% }); %>                  
      <%=_.template($( "#" + paramName + "-suggestions-template").html())()%>      
    </li>
    </ul>
  </script>
  
  <script type="text/template" id="COLLECTOR_NAME-suggestions-template">  
    <#list collectorSuggestions.suggestions?keys as name>            
      <div class="suggestionBox" data-suggestion="${name}">         
       <#assign suggestions = collectorSuggestions.suggestions[name]>
         <#if suggestions?has_content>
          <div class="warningBox"> <span class="warningCounter">!</span>The collector name  <strong>"${name}"</strong> didn't match any existing record.You can select one from the list below to try improving your search results.</div>                               
          <#list suggestions as suggestion>
              <input id="searchResult${suggestion}" type="radio" value="${suggestion}" name="COLLECTOR_NAME" class="suggestion" data-suggestion="${name}"/>
              <label for="searchResult${suggestion}">${suggestion}</label>                
              </br>                                                    
          </#list>           
         </#if>                  
      </div>               
     </#list>       
  </script>
  
  
  <script type="text/template" id="CATALOG_NUMBER-suggestions-template">  
    <#list catalogNumberSuggestions.suggestions?keys as name>            
      <div class="suggestionBox" data-suggestion="${name}">         
       <#assign suggestions = catalogNumberSuggestions.suggestions[name]>
         <#if suggestions?has_content>
          <div class="warningBox"> <span class="warningCounter">!</span>The catalog number  <strong>"${name}"</strong> didn't match any existing record. You can select one from the list below to try improving your search results.</div>                               
          <#list suggestions as suggestion>
              <input id="searchResult${suggestion}" type="radio" value="${suggestion}" name="CATALOG_NUMBER" class="suggestion" data-suggestion="${name}"/>
              <label for="searchResult${suggestion}">${suggestion}</label>                
              </br>                                                    
          </#list>           
         </#if>                  
      </div>               
     </#list>       
  </script>
  
  
  <script type="text/template" id="INSTITUTION_CODE-suggestions-template">  
    <#list institutionCodeSuggestions.suggestions?keys as name>            
      <div class="suggestionBox" data-suggestion="${name}">         
       <#assign suggestions = institutionCodeSuggestions.suggestions[name]>
         <#if suggestions?has_content>
          <div class="warningBox"> <span class="warningCounter">!</span>The catalog number  <strong>"${name}"</strong> didn't match any existing record. You can select one from the list below to try improving your search results.</div>                               
          <#list suggestions as suggestion>
              <input id="searchResult${suggestion}" type="radio" value="${suggestion}" name="INSTITUTION_CODE" class="suggestion" data-suggestion="${name}"/>
              <label for="searchResult${suggestion}">${suggestion}</label>                
              </br>                                                    
          </#list>           
         </#if>                  
      </div>               
     </#list>       
  </script>
  
  
  <script type="text/template" id="COLLECTION_CODE-suggestions-template">  
    <#list collectionCodeSuggestions.suggestions?keys as name>            
      <div class="suggestionBox" data-suggestion="${name}">         
       <#assign suggestions = collectionCodeSuggestions.suggestions[name]>
         <#if suggestions?has_content>
          <div class="warningBox"> <span class="warningCounter">!</span>The catalog number  <strong>"${name}"</strong> didn't match any existing record. You can select one from the list below to try improving your search results.</div>                               
          <#list suggestions as suggestion>
              <input id="searchResult${suggestion}" type="radio" value="${suggestion}" name="COLLECTION_CODE" class="suggestion" data-suggestion="${name}"/>
              <label for="searchResult${suggestion}">${suggestion}</label>                
              </br>                                                    
          </#list>           
         </#if>                  
      </div>               
     </#list>       
  </script>
  
  <script type="text/template" id="TAXON_KEY-suggestions-template">    
    <#list nameUsagesSuggestions.replacements?keys as sciname>   
      <#assign suggestion = nameUsagesSuggestions.replacements[sciname]>         
      <div class="suggestionBox" data-replacement="${sciname}">         
        <div class="warningBox"> <span class="warningCounter">!</span> The scientific name <strong>"${sciname}"</strong> was replaced by: <br>            
          ${suggestion.scientificName}                  
          <ul class="taxonomy">
            <#list suggestion.higherClassificationMap?values as classificationName>                    
              <li <#if !classificationName_has_next> class="last" </#if>>${classificationName}</li>
            </#list>
           </ul>
        </div>                               
      </div>               
     </#list>         
    <#list nameUsagesSuggestions.suggestions?keys as sciname>            
      <div class="suggestionBox" data-suggestion="${sciname}">         
       <#assign suggestions = nameUsagesSuggestions.suggestions[sciname]>
         <#if suggestions?has_content>
          <div class="warningBox"> <span class="warningCounter">!</span> We found more than one scientific name that matched <strong>"${sciname}"</strong>.Please select a name from the list below.</div>                               
          <#list suggestions as nameUsageSearchResult>
              <input id="searchResult${nameUsageSearchResult.key?c}" type="radio" value="${nameUsageSearchResult.key?c}" name="TAXON_KEY" class="suggestion" data-suggestion="${sciname}"/><label for="searchResult${nameUsageSearchResult.key?c}">${nameUsageSearchResult.scientificName}</label>
              </br>                
              <ul class="taxonomy">
                <#list nameUsageSearchResult.higherClassificationMap?values as classificationName>
                  <li <#if !classificationName_has_next> class="last" </#if>> ${classificationName} </li>
                </#list>
               </ul>              
              </br>                          
          </#list>
         <#else>
           <div class="warningBox"> <span class="warningCounter">${sciname_index + 1}</span> We haven't found any scientific name that matched <strong>"${sciname}"</strong>.</div>
         </#if>                  
      </div>               
     </#list>  
  </script>
  
  <script type="text/template" id="template-applied-filter">
    <li>    
      <div><div title="<%=title%>"><div class="filter_content"><%= label %><input name="<%= paramName %>" type="hidden" key="<%= key %>" value="<%= value %>"/><a class="closeFilter"></a></div></div></div>       
    </li>
  </script>
  
  <script type="text/template" id="template-location-filter">
    <li>    
      <div><div title="<%=title%>"><div class="filter_content">
      <%if (typeof(targetParam) != "undefined" && targetParam == 'POLYGON' ) {%><img src="../js/vendor/leaflet/draw/images/draw-polygon.png" class="geo_type"/> <%}
       else {%>
        <img src="../js/vendor/leaflet/draw/images/draw-rectangle.png" class="geo_type"/>
       <%}%>
      <%= label %><input name="<%= paramName %>" type="hidden" key="<%= key %>" value="<%= value %>" data-marker="<%= marker%>"/><a class="closeFilter removeGeo"></a></div></div></div>       
    </li>
  </script>
    
  <script type="text/template" id="map-template-filter">
     <tr class="filter">
      <td colspan="4">        
        <a class="edit" style="display:none;"/>
        <div class="inner filter_view">  
          <h4 class="title">Location</h4>                   
          <div id="bboxContainer">  
              <div style="width:300px;">
                <fieldset class="location_option_geo">
                  <legend>Show only records that are</legend>                
                  <label for="isGeoreferenced">georeferenced</label> <input type="checkbox" name="GEOREFERENCED" id="isGeoreferenced" value="true" <#if action.isInFilter('GEOREFERENCED', 'true')> checked</#if>/>
                  <span>&nbsp;&nbsp;&nbsp;&nbsp;</span>
                  <label for="isNotGeoreferenced">not georeferenced</label> <input type="checkbox" name="GEOREFERENCED" id="isNotGeoreferenced" value="false" <#if action.isInFilter('GEOREFERENCED', 'false') && !action.isInFilter('GEOREFERENCED', 'true')> checked</#if>/>
                </fieldset>
              </div>                            
              <fieldset class="location_option_geo">  
              <legend>Bounding box/Polygon</legend>                                                    
              <table>                
                <tr>    
                  <td>                                    
                     <div id="zoom_in" class="zoom_in"></div>
                     <div id="zoom_out" class="zoom_out"></div>
                     <div id="map" class="map_widget"/> 
                     <input name="polygon" id="polygon" type="hidden"/>                
                  </td>
                   <td>                          
                      <h4>Bounding box from</h4>  
                      <div style="display:none;" class="error bbox_error">The specified coordinates don't represent a valid bounding box, please verify the entered values.</div>                       
                      <br>            
                      <span>
                        <input name="minLatitude" id="minLatitude"  class="point" type="text" size="10" style="width:60px;"/>
                        <input name="minLongitude" id="minLongitude" class="point" type="text" size="10" style="width:60px;"/>
                      </span>
                      <br>             
                      <h4>To</h4>
                      <br>         
                      <span>
                        <input name="maxLatitude" id="maxLatitude" class="point" type="text" size="10" style="width:60px;"/>
                        <input name="maxLongitude" id="maxLongitude" class="point" type="text" size="10" style="width:60px;"/>
                      </span>
                      <br>
                      <input type="image" src="<@s.url value='/img/admin/add-small.png'/>" class="addFilter map_control">                      
                      <br>                                            
                      <h4 class="filtersTitle" style="display:none;">Filters</h4>
                      <div class="appliedFilters filterlist" style="display:none;"></div>                      
                      <br>                      
                  </td>
                </tr>                                 
              </table>
              </fieldset>
              <div style="width:490px;">
                <fieldset class="location_option_geo" id="spatial_issues">
                  <legend>Show only records</legend>                
                  <label for="noSpatialIssues">with no known coordinate issues</label> <input type="checkbox" name="SPATIAL_ISSUES" id="noSpatialIssues" value="false" <#if action.isInFilter('SPATIAL_ISSUES', 'false')> checked</#if> <#if action.isInFilter('GEOREFERENCED', 'false')> disabled</#if>/>
                  <span>&nbsp;&nbsp;&nbsp;&nbsp;</span>
                  <label for="spatialIssues">with known coordinate issues</label> <input type="checkbox" name="SPATIAL_ISSUES" id="spatialIssues" value="true" <#if action.isInFilter('SPATIAL_ISSUES', 'true')> checked</#if> <#if action.isInFilter('GEOREFERENCED', 'false')> disabled</#if>/>
                </fieldset>
              </div>
                <a class="button candy_blue_button apply left" title="<%= title %>" data-action="add-new-bbox-filter" data-filter="<%= paramName %>"><span>Apply</span></a>
           </div>                             
           <a class="close"></a>     
        </div>
        <div class="summary_view">          
          
        </div> 
       </td>
     </tr>
  </script>
