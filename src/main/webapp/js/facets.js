/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */  	
  $(function() {	  		  
	  $('.seeAllFacet').each( function(){
		 $("a.seeAllLink", this).bindDialogPopover($("div.dialogPopover", this));
	  });

	$('#resetFacetsButton').click( function(event){
		$('.facet input:checkbox').each( function(){this.checked = false});
		$('#formSearch input:hidden').remove();
    $('#resetFacets input.defaultFacet').appendTo($('#formSearch'));
		$('#formSearch').submit();
		showWaitDialog();
	});
	
    // toggle a facet box
    $('.facet ul li:not([class])').each( function(){
    	var thisLi = this;
    	$('a',thisLi).click( function(event){
    		event.preventDefault();
        // a facet link is equivalent to toggling the box
        var $checkbox = $('input',thisLi);
        $checkbox.attr('checked', !$checkbox.attr('checked'));
        $checkbox.click();
    	});
    	$('input',thisLi).click( function(event){
        // first lock all other facets so we dont get into concurrency problems
    		$('.facet input:checkbox').each(function(){
          $(this).attr('disabled','true');
        });
    		if(this.checked){
          addFacet(this.value);
    		}else{
          removeFacet(this.value);
    		}
    	})
  	 });


	  $('.facetFilter').each( function(){
      var span = $("span.flabel", this);
      var facetFilter = span.text().toLowerCase();
      var facetValue  = span.attr("val");
      $("a", this).click(function(event) {
        event.preventDefault();
        removeFacet(facetFilter, facetValue);
      });
	  });
	  
    // facetParam is the full query parameter e.g. rank=species
    function addFacet(facetParam) {
      var queryParams = currentQueryParams();
      queryParams.push(facetParam);
      changeLocation(queryParams.unique());
    }

    // facetParam is the full query parameter e.g. rank=species
    function removeFacet(facetParam) {
      var queryParams = currentQueryParams().unique();
      var idx = $.inArray(facetParam, queryParams);
      if (idx >= 0){
        queryParams.splice (idx,1);
      }
      changeLocation(queryParams);
    }
    
    function changeLocation(queryParams) {
      showWaitDialog();
      window.location.replace(window.location.pathname + '?' + queryParams.join('&'));
    }


    function showWaitDialog(){
    	$('#waitDialog').css("top", getTopPosition($('#waitDialog')) + "px");
      $('#waitDialog').fadeIn("medium", function() { hidden = false; });
      $("body").append("<div id='lock_screen'></div>");
	    $("#lock_screen").height($(document).height());
	    $("#lock_screen").fadeIn("slow");
    }

    function getTopPosition(div) {
      return (( $(window).height() - div.height()) / 2) + $(window).scrollTop() - 50;
    }

	  function currentQueryParams() {
      // get the pairs of params fist
      var pairs = unescape(location.search.substring(1)).split('&');
      var values = [];
      // now iterate each pair
      for (var i = 0; i < pairs.length; i++) {
        var params = pairs[i].split('=');
        if (params[0] != "limit" && params[0] != "offset") {
          values.push(pairs[i]);
        }
      }
      return values;
	  };
  })
