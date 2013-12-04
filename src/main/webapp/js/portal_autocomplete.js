/**
 * jquery ui is extended with a new highlight function.
 * This function highlights the input term in value result.
 */
$.extend($.ui.autocomplete.prototype,
  {highlight: function(value, term) {
    return value.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(" + term.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi, "\\$1") + ")(?![^<>]*>)(?![^&;]+;)", "gi"), "<strong>$1</strong>");
  }
  });

/**
 * Species name Autosuggest widget.
 * @param wsServiceUrl url to the search/suggest service
 * @param appendToElement parent element of generated widget
 * @param onSelectEventHandler function that handles the event when an element is selected
 */
$.fn.countryAutosuggest = function(countryList,appendToElement, onSelectEventHandler) {
  //reference to the widget
  var self = $(this);
  //jquery ui autocomplete widget creation
  self.autocomplete({
    source:function(request, response) {
      var matches = $.map( countryList, function(country) {
        if ( country.label.toUpperCase().indexOf(request.term.toUpperCase()) === 0 ) {
          return country;
        }
      });
      if (!matches || matches.length == 0) {
        matches.push({label:"No results found",iso2Lettercode:0});
      }
      response(matches);
    },
    create: function(event, ui) {
      //forcibly css classes are removed because of conflicts between existing styles and jquery ui styles
      $(".ui-autocomplete").removeClass("ui-widget-content ui-corner-all");
      $(".ui-autocomplete").css("z-index",1000);
    },
    open: function(event, ui) {
      $('.ui-autocomplete.ui-menu').addClass('autocomplete');
      $(".ui-autocomplete").css("z-index",1000);
    },
    appendTo: appendToElement,
    focus: function( event, ui ) {//on focus: sets the value of the input[text] element
      return false;
    },
    select: function( event, ui ) {//on select: sets the value of the input[text] element
      if (ui.item.iso2Lettercode != 0){
        self.attr("data-key",ui.item.iso2Lettercode);
        self.val( ui.item.label);
        if(onSelectEventHandler !== undefined) {
          onSelectEventHandler({key: ui.item.iso2Lettercode,value: ui.item.label,label: ui.item.label});
        }
      }
      return false;
    }
  }).data( "autocomplete" )._renderItem = function( ul, item) {
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append("<a class='name'>" + this.highlight(item.label,self.val()) + "</a>")
      .appendTo( ul );
    //last line customizes the generated elements of the auto-complete widget by highlighting the results and adding new css class
  };
};

/**
 * Dataset title Autosuggest widget.
 * @param wsSuggestUrl url to the suggest service
 * @param portalDatasetUrl url to portal dataset details page without the key
 * @param limit maximum elements expected/this can be overwritten by the server side implementation
 * @param appendToElement parent element of generated widget
 * @param onSelectEventHandler function that handles the event when an element is selected
 */
$.fn.datasetAutosuggest = function(wsSuggestUrl, limit, maxLength, appendToElement, onSelectEventHandler, datasetType) {
  //reference to the widget
  var self = $(this);
  //jquery ui autocomplete widget creation
  var defaultParams =  new Object();
  if( undefined != datasetType){
    defaultParams.type = datasetType;
  }
  self.autocomplete({source: function( request, response ) {
    $.ajax({
      url: wsSuggestUrl,
      dataType: 'jsonp', //jsonp is the default
      data: $.extend(defaultParams, {
        q: self.val(),
        limit: limit
      }),
      success: function(data){//response the data sent by the web service
        response( $.map(data, function( item ) {
          return {
            value: trucateAutosuggestValue(item.title, maxLength),
            label: item.title,
            key: item.key
          }
        }));
      }
    });
  },
    create: function(event, ui) {
      //forcibly css classes are removed because of conflicts between existing styles and jquery ui styles
      $(".ui-autocomplete").removeClass("ui-widget-content ui-corner-all");
      $(".ui-autocomplete").css("z-index",1000);
    },
    open: function(event, ui) {
      //a high z-index ensures that the autocomplete will be "always" visible on top of other elements
      $(".ui-autocomplete").css("z-index",1000);
    },
    appendTo: appendToElement,
    focus: function( event, ui ) {//on focus: sets the value of the input[text] element
      if (typeof(ui.item.key) != 'undefined') {
        self.attr("key",ui.item.key);
      }
      self.val( ui.item.value);
      return false;
    },
    select: function( event, ui ) {//on select: goes to dataset detail page
      if (typeof(ui.item.key) != 'undefined') {
        self.attr("key",ui.item.key);
      }
      self.val( ui.item.value);
      if(onSelectEventHandler !== undefined) {
        onSelectEventHandler(ui.item);
      }
      return false;
    }
  }).data( "autocomplete" )._renderItem = function( ul, item) {
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append("<a class='name'>" + this.highlight(item.value,self.val()) + "</a>")
      .appendTo( ul );
    //last line customizes the generated elements of the auto-complete widget by highlighting the results and adding new css class
  };
};

/**
 * Truncates autosuggest value if it exceeds max length, otherwise the original value is returned unchanged.
 * @param input autosuggest value to truncate
 * @param maxLength maximum length autosuggest value can be
 */
function trucateAutosuggestValue(input, maxLength)
{
  var value = input;
  if (input.length > maxLength) {
    value = input.substring(0, maxLength) + "…";
  }
  return value;
}

/**
 * Species name Autosuggest widget.
 * @param wsServiceUrl url to the search/suggest service
 * @param limit maximum elements expected/this can be overwritten by the server side implementation
 * @param chklstKeysElementsSelector jquery/css selector for get the values of checklists key/ can be null (assuming  a server side default)
 * @param appendToElement parent element of generated widget
 * @param onSelectEventHandler function that handles the event when an element is selected
 */
$.fn.speciesAutosuggest = function(wsServiceUrl,limit,chklstKeysElementsSelector,appendToElement,onSelectEventHandler) {
  //reference to the widget
  var self = $(this);
  //jquery ui autocomplete widget creation
  self.autocomplete({source: function( request, response ) {
    $.ajax({
      url: wsServiceUrl,
      dataType: 'jsonp', //jsonp is the default
      data: {
        q: self.val(),
        limit: limit,
        checklistKey: ( chklstKeysElementsSelector ? $.map($(chklstKeysElementsSelector),function(elem){return elem.value;}).pop() : undefined) //if the selector is null, the parameter is not sent
      },
      success: function(data){//response the data sent by the web service
        response( $.map(data, function( item ) {
          return {
            label: item.scientificName,
            value: item.scientificName,
            key: item.nubKey,
            rank: item.rank,
            higherClassificationMap: item.higherClassificationMap
          }
        }));
      }
    });
  },
    create: function(event, ui) {
      //forcibly css classes are removed because of conflicts between existing styles and jquery ui styles
      $(".ui-autocomplete").removeClass("ui-widget-content ui-corner-all");
      $(".ui-autocomplete").css("z-index",1000);
    },
    open: function(event, ui) {
      //a high z-index ensures that the autocomplete will be "always" visible on top of other elements
      $(".ui-autocomplete").css("z-index",1000);
    },
    appendTo: appendToElement,
    focus: function( event, ui ) {//on focus: sets the value of the input[text] element
      if (typeof(ui.item.key) != 'undefined') {
        self.attr("key",ui.item.key);
      }
      self.val( ui.item.value);
      return false;
    },
    select: function( event, ui ) {//on select: sets the value of the input[text] element
      if (typeof(ui.item.key) != 'undefined') {
        self.attr("key",ui.item.key);
      }
      self.val( ui.item.value);
      if(onSelectEventHandler !== undefined) {
        onSelectEventHandler(ui.item);
      }
      return false;
    }
  }).data( "autocomplete" )._renderItem = function( ul, item) {
    var divHigherClassificationMap = "";
    if(typeof(item.higherClassificationMap) != 'undefined'){
      divHigherClassificationMap = "<div class='taxonMapAutoComplete'><ul>";
      $(item.higherClassificationMap).each(function(idx) {
        $.each(this,function(name,value) {
          divHigherClassificationMap += "<li>" + value + "</li>";
        });
      });
      divHigherClassificationMap += "</ul></div>";
    }
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append("<a class='name'>" + this.highlight(item.value,self.val())  + (item.rank != null ? "<span class='autosuggestRank'> (" + item.rank + ")" : '') +  "</a>")
      .append(divHigherClassificationMap)
      .appendTo( ul );
    //last line customizes the generated elements of the auto-complete widget by highlighting the results and adding new css class
  };
};

/**
 * Simple Autosuggest widget.
 * Creates an Autosuggest widget using a web service, the web service response should be a list of strings.
 * @param wsServiceUrl url to the search/suggest service
 * @param appendToElement parent element of generated widget
 * @param limit maximum elements expected/this can be overwritten by the server side implementation
 * @param onSelectEventHandler function that handles the event when an element is selected
 */
$.fn.termsAutosuggest = function(wsServiceUrl,appendToElement,limit,onSelectEventHandler) {
  //reference to the widget
  var self = $(this);
  //jquery ui autocomplete widget creation
  self.autocomplete({source: function( request, response ) {
    $.ajax({
      url: wsServiceUrl,
      dataType: 'jsonp', //jsonp is the default
      data: {
        q: self.val(),
        limit: limit
      },
      success: function (data) { //response the data sent by the web service
        response(data);
      }
    });
  },
    create: function(event, ui) {
      //forcibly css classes are removed because of conflicts between existing styles and jquery ui styles
      $(".ui-autocomplete").removeClass("ui-widget-content ui-corner-all");
      $(".ui-autocomplete").css("z-index",1000);
    },
    open: function(event, ui) {
      //a high z-index ensures that the autocomplete will be "always" visible on top of other elements
      $(".ui-autocomplete").css("z-index",1000);
    },
    appendTo: appendToElement,
    focus: function( event, ui ) {//on focus: sets the value of the input[text] element
      self.val( ui.item.value);
      return false;
    },
    select: function( event, ui ) {//on select: sets the value of the input[text] element
      self.val( ui.item.value);
      if(onSelectEventHandler !== undefined ) {
        //key is required by templates and select handlers
        ui.item.key = ui.item.value;
        onSelectEventHandler(ui.item);
      }
      return false;
    }
  }).data( "autocomplete" )._renderItem = function( ul, item) {
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append("<a class='name'>" + this.highlight(item.value,self.val()) + "</a>")      
      .appendTo( ul );
    //last line customizes the generated elements of the auto-complete widget by highlighting the results and adding new css class
  };
};