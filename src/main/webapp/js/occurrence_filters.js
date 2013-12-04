/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF)
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * Occurrence filters module.
 * Implements functionality for widgets that follow the structure of templates: 
 * - template-add-filter: simple filter with 1 input.
 * - template-add-date-filter: occurrence date widget.
 * - map-template-filter: bounding box widget filter.
 * 
 *  Every time a filter is applied/closed a request is sent to the targetUrl parameter.
 *  Parameter "filters" contains a list of predefined filters that would be displayed as applied filters.
 *  The filters parameter must have the form: { title,value, year (valid for date filter only), month (valid for date filter only), key, paramName }
 *  
 */

//DEFAULT fade(in/out) time
var FADE_TIME = 250;

//Maximum size of filters label, 37 = 40 - 3 because of ... (suspensive points); so the real maximum is 40
var MAX_LABEL_SIZE = 40;

//Constant for suspensive points literal.
var SUSPENSIVE_POINTS = "...";

//Error CSS class for invalid input values.
var ERROR_CLASS = "error";

//predicates constants
//Greater than
var GT = "gt";

//Less than
var LT = "lt";

//Equals
var EQ = "eq";

var DEFAULT_SHAPE_OPTIONS = {color:"#f06eaa",weight:4};

//Default limit to all auto-complete widgets
var SUGGEST_LIMIT = 10;

//This is needed as a nasty way to address http://dev.gbif.org/issues/browse/POR-365
//The map is not correctly displayed, and requires a map.invalidateSize(); to be fired
//After the filter div is rendered.  Because of this the map scope is public.
var map;

var defaultMapLayer;

//Markers to display the bounding box boundaries.
var bboxMarkerLeft = null, bboxMarkerRight = null;

//Range formats used bu comparator and month widgets.
var predicatePatternMap = { 'lte':'*,%v','gte':'%v,*','eq':'%v','bt':'%v1,%v2' };

/**
 * Truncates a decimal value to 2 decimals length of precision.
 */
function truncCoord(value) {
  var newValue = value.toString();        
  var values = newValue.split('.');
  if (values.length > 1) {
    var decimalValue = values[1];
    if(decimalValue.length > 6) {
      decimalValue = decimalValue.slice(0, 6);
    }
    newValue = values[0] + '.' + decimalValue;
  }        
  return newValue;
};

/**
 * Base module that contains the base implementation for the occurrence widgets.
 * Contains the implementation for the basic operations: create the HTML control, apply filters, show the applied filters and close/hide the widget.
 */
var OccurrenceWidget = (function ($,_,OccurrenceWidgetManager) {  

  /**
   * Utility function that validates if the input string is empty.
   */
  function isBlank(str) {
    return (!str || /^\s*$/.test(str));
  };

  /**
   * Inner object/function used for returning the OccurenceWidget instance.
   */
  var InnerOccurrenceWidget = function () {        
  };

  //Prototype object extensions.
  InnerOccurrenceWidget.prototype = {

      /**
       * Default constructor.
       */
      constructor: InnerOccurrenceWidget,

      /**
       * Initializes the widget.
       * This function is not invoked during object construction to allow the executions of binding functions 
       * that usually are not required during object construction. 
       */
      init: function(options){
        this.filters = new Array();
        this.widgetContainer = options.widgetContainer;
        this.isBound = false;
        this.id = null;
        this.filterElement = null;
        this.summaryView = null;
        this.manager = options.manager;
        this.bindingsExecutor = options.bindingsExecutor;
        this.summaryTemplate = null;
      },

      //IsBlank
      isBlank : isBlank,

      /**
       * Validates if the input string is unsigned integer.
       */
      isUnsignedInteger: function(s) {
        return (s.search(/^[0-9]+$/) == 0);
      },

      /**
       * Checks is the input value is a valid number.
       * isDecimal: true/false if the value is a decimal number or not.
       * minValue/maxValue: range of accepted values, could be null.
       */
      isValidNumber : function(value,isDecimal,minValue,maxValue){
        if(value.length > 0){
          var numValue;
          if(isDecimal){
            numValue = parseFloat(value);
          }else{            
            if(!this.isUnsignedInteger(value)){
              return false;
            }
            numValue = parseInt(value);
          }
          if (isNaN(numValue)) {
            return false;
          }
          var validMinValue = (minValue == null || (numValue >= minValue));
          var validMaxValue = (maxValue == null || (numValue <= maxValue));          
          return (validMinValue && validMaxValue);
        }
        return true;
      },

      /**
       * Gets the widget identifier.
       * The id field should identify the widget in a page instance.
       */
      getId : function() {
        return this.id;
      },

      /**
       * Sets the widget identifier.
       */
      setId : function(id) {
        this.id = id;
      },

      /**
       * Returns the filters that have been applied  by the filter or by reading HTTP parameters. 
       */
      getFilters : function(){return this.filters;},

      /**
       * Shows the HTML widget.
       */
      open : function(){    
        if (!this.isVisible()) {
          this.filterElement.fadeIn(FADE_TIME);
          this.showFilters();
          this.showEditView();
          this.toggleApplyButton();          
        }
      },

      /**
       * Return true if the widget has been initialized.
       */
      isCreated : function(){
        return (this.filterElement)
      },

      /**
       * Closes (hides) the HTML widget.
       */
      close : function(){      
        if (this.filterElement != null) {          
          this.showSummaryView();          
        }
        //removes the filter that haven't been submitted
        this.removeNoSubmittedFilters();
        if(this.filters.length > 0) {
          this.filterElement.find('.edit').show();
        }
      },


      /**
       * Shows the summary view. Hides the filter edition view.
       */
      showSummaryView: function() { 
        if(this.filterElement != null) {
          var submittedFilters = this.getFiltersBySubmitted(true); 
          if(submittedFilters.length > 0) {
            var filterView = this.filterElement.find('.filter_view');
            if (!this.isCreated()) {
              this.createHTMLWidget(this.control);
            }
            if (!this.filterElement.is(':visible')) {
              this.filterElement.fadeIn(FADE_TIME);
            }
            this.initSummaryView($(this.control).attr('title'),submittedFilters);            
            if (filterView.is(':visible')) {
              var self = this;
              filterView.fadeOut(FADE_TIME,function(){ self.filterElement.find('.summary_view').fadeIn(FADE_TIME);});
            }else {
              this.filterElement.find('.summary_view').fadeIn(FADE_TIME);
            }
            this.bindRemoveFilterEvent();
            this.bindSuggestions();
          } else {
            this.filterElement.fadeOut(FADE_TIME);
          }
        }
      }, 

      /**
       * Shows the edit view. Hides the filter summary view.
       */
      showEditView: function(){   
        var self = this;
        if (!this.isCreated()) {
          this.createHTMLWidget(this.control);          
        }
        this.filterElement.fadeIn(FADE_TIME);
        this.filterElement.find('.summary_view').fadeOut(FADE_TIME,function(){ self.filterElement.find('.filter_view').fadeIn(FADE_TIME, function(){
          // This is needed to address http://dev.gbif.org/issues/browse/POR-365 
          // The solution was found 
          if (map!=null) { 
            map.invalidateSize(); 
          }          
        });});
        self.filterElement.find('.edit').hide();
        this.showFilters();        
      }, 

      /**
       * Remove all the filter whose filter.submitted field is false.
       */
      removeNoSubmittedFilters : function() {
        for (var i = 0; i < this.filters.length; i++) {
          if(!this.filters[i].submitted){
            this.filters.splice(i,1);
            i--; // decrement since length has changed
          }
        }
      },

      /**
       * Gets all the filters whose filter.submitted field is equals to submitted.
       */
      getFiltersBySubmitted : function(submitted) {
        var filteredFilters = new Array();
        for (var i = 0; i < this.filters.length; i++) {
          if(this.filters[i].submitted == submitted){
            filteredFilters.push(this.filters[i]);
          }
        }
        return filteredFilters;
      },

      /**
       * Determines if the widget is visible or not.
       */
      isVisible : function(){
        return ($(this.filterElement).is(':visible'));
      },

      /**
       * Adds the filter to the list of applied filters and executes the onApplyFilter event.
       */
      applyFilter : function(filterP) {
        this.addFilter(filterP);
        this.manager.applyOccurrenceFilters(true);
      },

      /**
       * Hides/shows the apply button if there are filters to be applied.
       */
      toggleApplyButton: function() {
        if(this.filterElement != null) {
          if(this.getNoSubmittedFiltersCount() > 0) {
            this.filterElement.find(".apply").show();
          } else {
            this.filterElement.find(".apply").hide();
          }
        }
      },

      /**
       * Gets the number no submitted filters.
       */
      getNoSubmittedFiltersCount : function() {
        var noSubCount = 0;
        for (var i = 0; i < this.filters.length; i++) {
          if(!this.filters[i].submitted){
            noSubCount++;
          }
        }
        return noSubCount;
      },

      /**
       * Adds a filter to the list of filters.
       */
      addFilter : function(filter) {        
        if (!this.existsFilter(filter)) {
          this.filters.push(filter);
        }
        this.toggleApplyButton();
      },

      /**
       * Binds the widget to an HTML element.
       * The click event of the control parameters shows the widget.
       */
      bindToControl: function(control) {
        this.control = control;
        if(!this.getId()){                    
          this.setId($(control).attr("data-filter"));   
          var widget = this;
          widget.create($(control));
          widget.showSummaryView();
          $(control).on("click", function(e) {
            e.preventDefault();
            widget.showEditView();
          });
        }
      },

      /**
       * Limit the size of the text to MAX_LABEL_SIZE.
       * If the size of the text y greater than MAX_LABEL_SIZE, the size is limited to that max and suspensive points are added at the end. 
       */
      limitLabel: function(label) {
        var newLabel = label;        
        if(newLabel.length >= MAX_LABEL_SIZE){
          newLabel = newLabel.slice(0,MAX_LABEL_SIZE) + SUSPENSIVE_POINTS;
        }
        return newLabel;
      },

      getFilterItemTemplate: function () {
        return "#template-applied-filter";
      },

      /**
       * Shows the list of html elements with the css class "filters". 
       */
      showFilters : function() {
        if(this.filterElement != null) { //widget was created          
          var appliedFilters = this.filterElement.find(".appliedFilters");
          //clears the HTML list of filters, the list is rebuilt each time this function is called
          appliedFilters.empty(); 
          //HTML element that will hold the list of filters
          var filtersContainer = $("<ul style='list-style: none;display:block;'></ul>"); 
          appliedFilters.append(filtersContainer); 
          //gets the HTML template for filters
          var templateFilter = _.template($(this.getFilterItemTemplate()).html());
          var self = this;
          var filterAdded = false;
          for(var i=0; i < this.filters.length; i++) {
            if( this.filters[i].hidden == undefined || !this.filters[i].hidden) {
              filterAdded = true;
              //title field used for attribute <INPU title="currentFilter.title">
              var currentFilter = $.extend(this.filters[i], {title: this.filters[i].label, label:this.limitLabel(this.filters[i].label)});            
              var newFilter = $(templateFilter(currentFilter));
              if( i != this.filters.length - 1){
                $(newFilter).append('</br>');
              }
              //adds each filter to the list using the HTML template
              filtersContainer.append(newFilter);   
              //The click event of element with css class "closeFilter" handles the filter removing and applying the filters 
              newFilter.find(".closeFilter").click( function(e) {
                var input = $(this).parent().find(':input[name=' + self.getId() + ']');              
                self.removeFilter({value: input.val(), key: input.attr('key'), paramName: input.attr('name')});
                self.showFilters();
              });
            }          
          }
          this.filterElement.find(".appliedFilters,.filtersTitle").toggle(filterAdded);
        }
      },

      /**
       * Creates the HTML widget if it was not created previously, then the widget is shown.
       */
      create : function(control) {
        if (!this.isCreated()) {
          this.createHTMLWidget(control);          
        }
      },

      /**
       * Utility function that renders/creates the HTML widget.
       */
      createHTMLWidget : function(control){        
        var          
        placeholder = $(control).attr("data-placeholder"),
        templateFilter = $(control).attr("data-template-filter"),        
        inputClasses = $(control).attr("data-input-classes") || {},
        title = $(control).attr("title"),
        template = _.template($("#" + templateFilter).html()),
        submittedFilters = this.getFiltersBySubmitted(true);

        this.summaryTemplate = $(control).attr("data-template-summary")

        this.filterElement = $(template({title:title, paramName: this.getId(), placeholder: placeholder, inputClasses: inputClasses }));        
        this.filterElement.find(".apply").hide();
        this.widgetContainer.after(this.filterElement);
        this.initSummaryView(title,submittedFilters);
        this.bindEditHover();
        this.bindCloseControl();
        this.bindAddFilterControl();
        this.bindApplyControl();     
        this.executeAdditionalBindings();        
      },

      /**
       * Binds the edit event on hover the filter container.
       */
      bindEditHover: function() {
        var self = this;
        this.filterElement.find('a.edit').click( function(e) {
          self.showEditView();
          $(this).hide();
        });

        this.filterElement.hover( 
            function(e){
              if(self.filterElement.find('.filter_view').is(':visible')){
                self.filterElement.find('.edit').hide();
                return;
              }
              if(self.summaryView.is(':visible')){
                self.filterElement.find('.edit').show();
              }
            },
            function(e){
              if(self.filterElement.find('.filter_view').is(':visible')){
                self.filterElement.find('.edit').hide();
                return;
              }
              if(self.summaryView.is(':visible')){
                self.filterElement.find('.edit').hide();
              }
            }
        );
      },

      /**
       * Initializes the summary view. It will be hidden by default.
       */
      initSummaryView : function(title,submittedFilters){
        var sumaryViewTemplate = _.template($("#" + this.summaryTemplate).html());        
        this.summaryView = this.filterElement.find('.summary_view'); 
        this.summaryView.html('');
        this.summaryView.prepend($(sumaryViewTemplate({paramName: this.getId(), title:title, filters: submittedFilters})));
        this.summaryView.hide();
      },

      /**
       * Executes binding function bound during the object construction.
       */
      executeAdditionalBindings : function(){this.bindingsExecutor.call();},

      /**
       * Binds the close control to the close function.
       */
      bindCloseControl : function () {
        var self = this;
        this.filterElement.find(".close").click(function(e) {
          e.preventDefault();
          self.close();
        });
      },

      /**
       * Removes a filter and then re-display the list of filters.
       */
      removeFilter :function(filter) {        
        for (var i = 0; i < this.filters.length; i++) {
          if(this.filters[i].value == filter.value){
            var removedFilter = this.filters[i];
            this.filters.splice(i,1);            
            this.showFilters();
            if(removedFilter.submitted){
              this.filterElement.find(".apply").show();
            }
            return;            
          }
        }        
      },

      /**
       * Removes filters by the paramName field.
       */
      removeFilterByParamName :function(paramName) {        
        for(var i = 0; i < this.filters.length; i++){
          if(this.filters[i].paramName == paramName){
            this.filters.splice(i,1);         
            i--; //decrement since length has changed
          }
        }        
      },

      /**
       * Searches a filter by its value.
       */
      existsFilter :function(filterP) {        
        for(var i = 0; i < this.filters.length; i++){
          if(this.filters[i].value == filterP.value){
            return true;
          }
        }
        return false;
      },

      /**
       * Searches a filter by its value.
       */
      clearFilters :function() { 
        this.filters = new Array();
        this.showFilters();
        this.toggleApplyButton();
      },

      /**
       * Binds a widget apply control.
       * The apply control is used when the widgets handles several filters at a time and those should be submitted in one call.
       */
      bindApplyControl : function() {
        var self = this;
        this.filterElement.find("a.button[data-action]").click( function(e){
          if(self.filterElement.find(".addFilter").size() != 0) { //has and addFilter control
            //gets the value of the input field            
            var input = self.filterElement.find(":input[name=" + self.id + "]:first");                    
            var value = input.val();            
            if (!isBlank(value) && !self.existsFilter({value:value})) {
              var key = null;
              //Auto-complete widgets store the selected key in "key" attribute
              if (input.attr("key") !== undefined) {
                key = input.attr("key"); 
              }
              if ((typeof(value) != "string") && $.isArray(value)) {
                var values_idx = 0;
                while (values_idx < value.length) {
                  self.applyFilter({value: value[values_idx], key:key});
                  values_idx = values_idx + 1;
                }
              } else {
                self.applyFilter({value: value, key:key});
              }
              self.close();
            } else {
              self.manager.applyOccurrenceFilters(false);
            }
          } else {
            self.manager.applyOccurrenceFilters(false);
          }
        });  
      },      

      /**
       * The add filter control, handler how each individual filter is added to the list of filters.
       * The enter key, by default, adds/applies the filter.
       */
      bindAddFilterControl : function() {
        var self = this;
        var input = this.filterElement.find(":input[name=" + this.getId() + "]");
        this.bindAutoAddControl(input);
        this.filterElement.find(".addFilter").click( function(e){          
          self.addFilterControlEvent(self, input);
        });  
      },
      
      bindAutoAddControl: function(input){
        var self = this;        
        if ($(input).hasClass('auto_add')) {
          input.keyup(function(event){
            if(event.keyCode == 13){
              self.addFilterControlEvent(self, input);
            }
          });
        }
      },

      /**
       * Binds the close/remove event to HTML element with the css class "closeFilter".
       */
      bindRemoveFilterEvent : function(){
        var self = this;
        this.filterElement.find(".closeFilter").each(function(idx,element){      
          $(element).click(function(e){
            e.preventDefault();
            var
            filterContainer = $(this).parent().parent(),
            li = filterContainer.parent(),
            input = filterContainer.find(":input[type=hidden]");            
            self.removeFilter({key:input.attr("key"), value:input.val(), paramName: input.attr("name")});
            filterContainer.fadeOut(FADE_TIME, function(){                          
              $(this).remove();
              if(li.find("div.filter").length == 0){
                var ul = li.parent();
                li.remove();
                if(ul.find("li").length == 0) { // element about to be removed was the last one
                  //Removes the parent tr element
                  ul.parent().remove();
                }
              }
              //call the onCloseEvent if any
              self.manager.applyOccurrenceFilters(false);
              self.removeUnusedSuggestionBoxes();
            });        
          });
        });
      },

      /**
       * Utility function that validates if the input value is valid (non-blank) and could be added to list of filters.
       */
      addFilterControlEvent : function (self,input){        
        //gets the value of the input field            
        var value = input.val();            
        if(!isBlank(value)){            
          var key = null;
          //Auto-complete stores the selected key in "key" attribute
          if (input.attr("key") !== undefined) {
            key = input.attr("key"); 
          }
          self.addFilter({label:value,value: value, key:key,paramName:self.getId(), submitted: false});            
          self.showFilters();
          input.val('');
        }
      },


      /**
       * Determines if a filter with value parameter exists.
       */
      hasFilterWithValue: function(value) {
        for(var i = 0;  i < this.filters.length; i++){
          if (this.filters[i].value == value) {
            return true;
          }
        }
        return false;
      },

      /**
       * Removes the suggestions boxes that are not applicable.
       * Some of them could be obsolete because the user previously selected a suggestion.
       */
      removeUnusedSuggestionBoxes: function() {
        var self = this;
        $(".suggestionBox[data-suggestion]").each( function(idx,el) {
          var suggestion = $(el).attr('data-suggestion');
          if(!self.hasFilterWithValue(suggestion)){
            $(el).remove();
          }
        });
      },

      /**
       * Binds the click(checked) event of a suggestion item to perform several actions: 
       * removed the old filter value, update the occurrence widget, replace the UI content and then adds the filter.
       */
      bindSuggestions: function() {
        var self = this;
        $('input.suggestion').click( function(e) {          
          var filterContainer = $('div.filter:has(input[value="'+ $(this).attr('data-suggestion') +'"][type="hidden"])');
          if (filterContainer) {                         
            var thisValue = $(this).val();
            var newFilter = {label:$('label[for="searchResult' + thisValue + '"]').text(), paramName:$(this).attr('name'),value:thisValue,key:thisValue, submitted: false};            
            $(this).attr('checked',true);
            self.replaceFilterValues($(filterContainer).find(":input[type=hidden]").val(),newFilter);
            self.showSummaryView();            
            //remove the container div
            $(this).parent().remove();                       
            self.manager.applyOccurrenceFilters(false);  
            return true;
          }
        });
      },

      /**
       * Replace all the filters with filter.value == oldValue, with the values taken from parameter newFilter.
       */
      replaceFilterValues: function(oldValue, newFilter){
        for(var i = 0;  i < this.filters.length; i++){
          if(this.filters[i].value == oldValue){
            this.filters[i].value = newFilter.value;
            this.filters[i].key = newFilter.key;
            this.filters[i].label = newFilter.label;
          }
        }
      },
  }

  return InnerOccurrenceWidget;
})(jQuery,_,OccurrenceWidgetManager);

/**
 * Occurrence date widget. Allows specify single and range of dates.
 */
var OccurrenceMonthWidget = (function ($,_,OccurrenceWidget) {

  var InnerOccurrenceMonthWidget = function () {        
  };

  //Inherits everything from the OccurrenceWidget module.
  InnerOccurrenceMonthWidget.prototype = $.extend(true,{}, new OccurrenceWidget());

  /**
   * Validates if the filter value exists for the input predicate.
   */
  InnerOccurrenceMonthWidget.prototype.bindOnPredicateChange = function() {
    var self = this;
    this.filterElement.find(":input[name=predicate]").dropkick({
      change: function (value, label) {
        if(value == 'bt'){
          self.filterElement.find("#maxValue").show();
        } else {
          self.filterElement.find("#maxValue").hide();
        }     
      }
     });       
  };

  /**
   * Executes binding function bound during the object construction.
   */
  InnerOccurrenceMonthWidget.prototype.executeAdditionalBindings = function() {      
    this.bindingsExecutor.call();
    this.bindOnPredicateChange();
  };
  
  /**
   * Validates if the date range is:monthMin < monthMax.
   */
  InnerOccurrenceMonthWidget.prototype.isValidMonthRange = function(monthMin, monthMax) {  
    if(monthMin == 0){
      this.filterElement.find(":input[name=monthMin]:first,#dk_container_monthMin").addClass(ERROR_CLASS);
      return false;
    }
    if(monthMax != null && monthMin > monthMax) {
      this.filterElement.find("#monthRangeErrorMessage").show();
      this.filterElement.find(":input[name=monthMax]:first,:input[name=monthMin]:first,#dk_container_monthMax,#dk_container_monthMin").addClass(ERROR_CLASS);      
      return false;
    }
    return true;
  };

  //The bindAddFilterControl is re-defined, the define dates are validated and then added.
  InnerOccurrenceMonthWidget.prototype.bindAddFilterControl = function() {
    var self = this;
    $('.date-dropdown').dropkick(); // adds custom dropdowns

    $(document).on('click','#dk_container_monthMin > [class*="dk"], #dk_container_monthMax > [class*="dk"]', function(e) {      
      self.filterElement.find("#monthRangeErrorMessage").hide();
    });

    this.filterElement.find('.helpPopup').each( function(idx,el){
      $(el).prepend('<img src="'+((cfg.context+"/img/icons/questionmark.png").replace("//", "/")) +'"/> ').sourcePopover({"title":$(el).attr("title"),"message":$(el).attr("data-message"),"remarks":$(el).attr("data-remarks")});
    });

    this.filterElement.find(".addFilter").click( function(e) { 
      e.preventDefault();   
      self.filterElement.find('.' + ERROR_CLASS).removeClass(ERROR_CLASS)
      self.filterElement.find("#monthRangeErrorMessage").hide();
      self.filterElement.find(".month_error").hide();      
      var monthMin = parseInt(self.filterElement.find(":input[name=monthMin]:first").val());      
      var monthMax = null;
      var predicate = self.filterElement.find(':input[name=predicate] option:selected').val();
      var predicateText = self.filterElement.find(':input[name=predicate] option:selected').text();      
      var label = $(":input[name=monthMin]").find(":selected").text();      
      
      var isRangeQuery = self.filterElement.find("#maxValue").is(":visible");
      if(isRangeQuery){
        monthMax = parseInt(self.filterElement.find(":input[name=monthMax]:first").val());
        label = label + " and " +  $(":input[name=monthMax]").find(":selected").text();
      }
     
      var rangeValue = null;
      if(predicate == 'bt') { // is between predicate
        rangeValue = predicatePatternMap[predicate].replace('%v1',monthMin).replace('%v2',monthMax);
      } else {
        rangeValue = predicatePatternMap[predicate].replace('%v',monthMin);
      }
       
      if(!self.existsFilter({value: rangeValue}) && self.isValidMonthRange(monthMin,monthMax)){                                    
        self.filterElement.find("#monthRangeErrorMessage").hide();
        self.addFilter({label:predicateText + ' ' + label,value: rangeValue, key:null,paramName:self.getId(),submitted: false});
        self.showFilters();        
      }      
    });
  }      
  return InnerOccurrenceMonthWidget;
})(jQuery,_,OccurrenceWidget);

/**
 * Location widget. Displays a map that allows select a range bounding box area.
 */
var OccurrenceLocationWidget = (function ($,_,OccurrenceWidget) {
  var InnerOccurrenceLocationWidget = function () {         
    this.mapGeometries = new Array();
  }; 

  //Inherits everything from the OccurrenceWidget module.
  InnerOccurrenceLocationWidget.prototype = $.extend(true,{}, new OccurrenceWidget());

  InnerOccurrenceLocationWidget.prototype.getFilterItemTemplate = function(){
    return "#template-location-filter";
  };

  /**
   * Renumber the property data-marker for each bonding box and polygon.
   * This is need it 
   */
  InnerOccurrenceLocationWidget.prototype.renumberMarkers = function(){
    //renumbering markers
    this.filterElement.find(":input[data-marker]").each( function(idx,el) {
      $(el).attr("data-marker",idx);
    });
  };
  
  
  /**
   * The bindAddFilterControl function is re-defined to validate and process the coordinates. 
   */
  InnerOccurrenceLocationWidget.prototype.bindAddFilterControl = function() {
    var self = this;
    this.filterElement.find(".addFilter").click( function(e) { 
      e.preventDefault();
      $(".bbox_error").hide();
      self.filterElement.find('.' + ERROR_CLASS).removeClass(ERROR_CLASS);
      var minLat = self.filterElement.find(":input[name=minLatitude]:first").val();
      var minLng = self.filterElement.find(":input[name=minLongitude]:first").val();
      var maxLat = self.filterElement.find(":input[name=maxLatitude]:first").val();
      var maxLng = self.filterElement.find(":input[name=maxLongitude]:first").val();

      if((!self.isBlank(minLat) && !self.isValidNumber(minLat,true,-90,90)) || self.isBlank(minLat)){
        self.filterElement.find(":input[name=minLatitude]:first").addClass(ERROR_CLASS);
        return;
      }

      if((!self.isBlank(minLng) && !self.isValidNumber(minLng,true,-180,180)) || self.isBlank(minLng)){
        self.filterElement.find(":input[name=minLongitude]:first").addClass(ERROR_CLASS);
        return;
      }

      if((!self.isBlank(maxLat) && !self.isValidNumber(maxLat,true,-90,90)) || self.isBlank(maxLat)){
        self.filterElement.find(":input[name=maxLatitude]:first").addClass(ERROR_CLASS);
        return;
      }

      if((!self.isBlank(maxLng) && !self.isValidNumber(maxLng,true,-180,180)) || self.isBlank(maxLng)){
        self.filterElement.find(":input[name=maxLongitude]:first").addClass(ERROR_CLASS);
        return;
      }
      
      var bounds = self.truncateLatLngBounds(new L.LatLngBounds(new L.LatLng(minLat,minLng), new L.LatLng(maxLat,maxLng)));    
      if(self.isValidBBox(bounds)) {
        $(".bbox_error").hide();
        var label = "From " + minLat + ',' + minLng + ' To ' + maxLat + ',' + maxLng;
        self.filterElement.find(".point").val('');
        var numFilters = self.getFilters().length;        
        var rectangle = new L.Rectangle(bounds,DEFAULT_SHAPE_OPTIONS);
        self.addFilter({label: label, value: self.getPolygonFromRect(rectangle), key: null, paramName: self.getId(), submitted: false, marker: self.mapGeometries.length, targetParam:'BOUNDING_BOX'});      
        //GEOREFERENCED filters must be removed
        self.removeFilterByParamName('GEOREFERENCED');      
        self.filterElement.find(':checkbox[name="GEOREFERENCED"]').removeAttr('checked');      
        if(numFilters < self.getFilters().length) { //nothing changed
          self.showFilters();              
          rectangle.bindPopup("Bounding box: " + label);
          self.mapGeometries.push(rectangle);
          defaultMapLayer.addLayer(rectangle);
        }        
      } else {
        $(".bbox_error").addClass(ERROR_CLASS).show();
      }
    })
  };
  
  /**
   * Converts a list of lat/lng into a String with the form: lng1 lat1,lng2 lat2...
   */
  InnerOccurrenceLocationWidget.prototype.latLngsToPolygon = function(latLngs) {
    var value = "";
    $.each(latLngs, function(idx,el){
      value += truncCoord(latLngs[idx].lng) + " " + truncCoord(latLngs[idx].lat) + ",";
    });    
    value += truncCoord(latLngs[0].lng) + " " + truncCoord(latLngs[0].lat);
    return value;
  };

  /**
   * Binds the event handler to the add_polygon event.
   */
  InnerOccurrenceLocationWidget.prototype.bindAddPolygonEvent = function(){
    var self = this;
    $(document).on("add_polygon", function(e) {
      var coords =  self.latLngsToPolygon(e.poly.getLatLngs());  
      var coordsSplit = coords.split(",");
      self.addFilter({label:coordsSplit[0] + "..." + coordsSplit[coordsSplit.length - 2],value: coords, key:null,paramName:self.getId(), submitted: false, targetParam:'POLYGON', marker: self.mapGeometries.length, hidden:false});
      self.showFilters();      
      e.poly.bindPopup('Polygon:' + coords);
      e.mapLayer.addLayer(e.poly);
      self.mapGeometries.push(e.poly);
      self.renumberMarkers();
    });
  };
  
  
  /**
   * Binds the event handler to the add_polygon event.
   */
  InnerOccurrenceLocationWidget.prototype.getPolygonFromRect = function(rect){
    var latLngs = rect.getLatLngs();            
    return truncCoord(latLngs[1].lng) + " " + truncCoord(latLngs[1].lat) + "," +  truncCoord(latLngs[0].lng) + " " + truncCoord(latLngs[0].lat) 
    + "," + truncCoord(latLngs[3].lng) + " " + truncCoord(latLngs[3].lat) + "," + truncCoord(latLngs[2].lng) + " " + truncCoord(latLngs[2].lat) + "," + truncCoord(latLngs[1].lng) + " " + truncCoord(latLngs[1].lat);
  };
  
  
  /**
   * Binds the event handler to the add_polygon event.
   */
  InnerOccurrenceLocationWidget.prototype.truncateLatLngBounds = function(latLngBounds){
    var southWest = new L.LatLng(truncCoord(latLngBounds.getSouthWest().lat), truncCoord(latLngBounds.getSouthWest().lng)),      
    northEast = new L.LatLng(truncCoord(latLngBounds.getNorthEast().lat), truncCoord(latLngBounds.getNorthEast().lng));
    return new L.LatLngBounds(southWest, northEast);
  };
  
  
  /**
   * Checks if the bounding box is valid.
   */
  InnerOccurrenceLocationWidget.prototype.isValidBBox = function(latLngBounds) {
    return latLngBounds.isValid() && latLngBounds.getCenter().distanceTo(latLngBounds.getSouthWest()) > 1 &&
    latLngBounds.getSouthWest().distanceTo(latLngBounds.getNorthWest()) != 0 && latLngBounds.getSouthWest().distanceTo(latLngBounds.getSouthEast()) != 0;
  };

  /**
   * Binds the event handler to the add_bounding_box event.
   */
  InnerOccurrenceLocationWidget.prototype.bindAddBBoxEvent = function() {
    var self = this;    
    $(document).on("add_bounding_box",function(e) {      
      var calcLatLngBounds = self.truncateLatLngBounds(e.rect.getBounds());
      //BBoxes with a diagonal and squared distnace less than 1 meter are not valid
      if(!self.isValidBBox(calcLatLngBounds)) {
        map.removeLayer(e.rect);
        return;
      }
      var pointsLabel = calcLatLngBounds.getSouthWest().lat + ',' + calcLatLngBounds.getSouthWest().lng + ' To ' + calcLatLngBounds.getNorthEast().lat + ',' + calcLatLngBounds.getNorthEast().lng;
      var label = "From " + pointsLabel;
      self.addFilter({label:label,value: self.getPolygonFromRect(e.rect), key:null,paramName:self.getId(), submitted: false,targetParam:'BOUNDING_BOX',marker: self.mapGeometries.length, hidden:false});
      self.showFilters();            
      e.rect.bindPopup("Bounding box: from " + pointsLabel);
      e.mapLayer.addLayer(e.rect);
      self.mapGeometries.push(e.rect);
      self.renumberMarkers();
    });
  };

  /**
   * Binds the event handler to the .geo_type.click event.
   */
  InnerOccurrenceLocationWidget.prototype.bindSelectGeoEvent = function() {
    var self = this;    
    $(document).on("click",".geo_type", function(e) {      
        var input = $(this).next();
        var firstCoord = input.val().replace("POLYGON((","").replace("))","").split(",")[0].split(" ");
        var marker = parseInt(input.attr('data-marker'));
        map.panTo(new L.LatLng(firstCoord[1], firstCoord[0]));
        self.mapGeometries[marker].openPopup();      
    });
  };

  InnerOccurrenceLocationWidget.prototype.getGeometries = function(){ return this.mapGeometries;},
  
  InnerOccurrenceLocationWidget.prototype.addGeometry = function(geometry){ return this.mapGeometries.push(geometry);},
  /**
   * Binds the event handler to the .removeGeo.click event.
   */
  InnerOccurrenceLocationWidget.prototype.bindRemoveGeoEvent = function() {
    var self = this;    
    $(document).on("click",".removeGeo", function(e) {
      var input = $(this).prev();
      var marker = parseInt(input.attr('data-marker'));
      $("#map").trigger('click');
      map.closePopup(); //close popups if any is open
      map.removeLayer(self.mapGeometries[marker]);      
      self.mapGeometries.splice(marker,1);
      self.renumberMarkers();
    });    
  };
  
  /**
   * Removes all the polygons from the map.
   */
  InnerOccurrenceLocationWidget.prototype.removeAllPolygons = function() {
    var self = this;    
    for(var i = 0; i < this.mapGeometries.length; i++) {
      map.removeLayer(this.mapGeometries[i]);  
    }    
  };

  /**
   * Binds the event handler to the .checkbox[name="GEOREFERENCED"].change event.
   */
  InnerOccurrenceLocationWidget.prototype.bindSelectGeoreferecendEvent = function() {
    var self = this;    
    this.filterElement.find(':checkbox[name="GEOREFERENCED"]').change( function(e) {
      self.removeFilterByParamName('GEOREFERENCED');      
      if ($(this).attr('checked')) {
        self.filterElement.find(".map_control,.leaflet-control-draw").hide();
        self.removeFilterByParamName(self.getId());
        self.removeAllPolygons();
        var val = $(this).val();
        self.filters.push({label:val == 'true' ?'Yes':'No',value: val, key: null,paramName:'GEOREFERENCED', submitted: false,hidden:true});
        self.filterElement.find(':checkbox[name="GEOREFERENCED"][id!=' + $(this).attr('id') + ']').removeAttr('checked');
        if(val == 'false'){
          self.removeFilterByParamName('SPATIAL_ISSUES');
          self.filterElement.find(':checkbox[name="SPATIAL_ISSUES"]').removeAttr('checked');
          self.filterElement.find('#spatial_issues > :input').attr('disabled','disabled');
        } else {
          self.filterElement.find('#spatial_issues > :input').removeAttr('disabled');          
        }
      } else {
        self.filterElement.find(".map_control,.leaflet-control-draw").show();
      }
      if ($(this).attr('id') == 'isNotGeoreferenced') {
        self.filterElement.find('#spatial_issues > :input').removeAttr('disabled');        
      }
      self.showFilters();
      self.filterElement.find(".apply").show();
    });
  };
  
  /**
   * Binds the event handler to the .checkbox[name="SPATIAL_ISSUES"].change event.
   */
  InnerOccurrenceLocationWidget.prototype.bindSelectSpatialIssuesEvent = function() {
    var self = this;    
    this.filterElement.find(':checkbox[name="SPATIAL_ISSUES"]').change( function(e) {  
      self.removeFilterByParamName('SPATIAL_ISSUES');
      self.filterElement.find(':checkbox[name="SPATIAL_ISSUES"]').each( function(idx,el) {
        if ($(el).attr('checked')) {
          self.filters.push({label:$(el).val() == 'true' ?'Yes':'No',value: $(el).val(), key:null,paramName:'SPATIAL_ISSUES', submitted: false, hidden:true});             
        }
      });
      self.showFilters();
      self.filterElement.find(".apply").show();
    });
  };

  /**
   * Executes binding function bound during the object construction.
   */
  InnerOccurrenceLocationWidget.prototype.executeAdditionalBindings = function() {    
    this.bindingsExecutor.call();
    this.bindAddPolygonEvent();
    this.bindAddBBoxEvent();
    this.bindSelectGeoEvent();
    this.bindRemoveGeoEvent();
    this.bindSelectGeoreferecendEvent();
    this.bindSelectSpatialIssuesEvent();
  };  
  
  /**
   * Removes a filter and then re-display the list of filters.
   */
  InnerOccurrenceLocationWidget.prototype.removeFilter  = function(filter) {        
    for (var i = 0; i < this.filters.length; i++) {
      if(this.filters[i].paramName == filter.paramName && this.filters[i].value == filter.value){
        var removedFilter = this.filters[i];
        this.filters.splice(i,1);            
        this.showFilters();
        if(removedFilter.submitted){
          this.filterElement.find(".apply").show();
        }
        return;            
      }
    }        
  };


  return InnerOccurrenceLocationWidget;
})(jQuery,_,OccurrenceWidget);


/**
 * Comparator widget. Displays an selection list of available comparators (=,>,<) and an input box for the value.
 */
var OccurrenceComparatorWidget = (function ($,_,OccurrenceWidget) {
  
  var InnerOccurrenceComparatorWidget = function () {   
    this.unit = "";
  }; 
  
  //Inherits everything from the OccurrenceWidget module.
  InnerOccurrenceComparatorWidget.prototype = $.extend(true,{}, new OccurrenceWidget());
  
  /**
   * Validates if the filter value exists for the input predicate.
   */
  InnerOccurrenceComparatorWidget.prototype.bindOnPredicateChange = function() {
    var self = this;
    this.filterElement.find(":input[name=predicate]").dropkick({
      change: function (value, label) {
        if(value == 'bt'){
          self.filterElement.find("#maxValue").show();
        } else {
          self.filterElement.find("#maxValue").hide();
        }     
      }
     });         
  };
  
  /**
   * Sets the unit value.
   */
  InnerOccurrenceComparatorWidget.prototype.setUnit = function(unitP){
    this.unit = unitP;
  };
  
  /**
   * Gets the unit value.
   */
  InnerOccurrenceComparatorWidget.prototype.getUnit = function(){
    return this.unit;
  };

  /**
   * Executes binding function bound during the object construction.
   */
  InnerOccurrenceComparatorWidget.prototype.executeAdditionalBindings = function() {      
    this.bindingsExecutor.call();
    this.bindOnPredicateChange();    
    this.bindAutoAddControl(this.filterElement.find(":input[name=" + this.getId() + "Max]"));
  };

  /**
   * The bindAddFilterControl function is re-defined to validate and process the coordinates. 
   */
  InnerOccurrenceComparatorWidget.prototype.addFilterControlEvent = function (self,input) {        
    //gets the value of the input field        
    var inputMinValue = this.filterElement.find("input[name=" + this.getId() + "]");
    var value = inputMinValue.val();     
    var valueMax = null;
    var inputMaxValue = this.filterElement.find("input[name=" + this.getId() + "Max]");
    inputMinValue.removeClass(ERROR_CLASS);
    inputMaxValue.removeClass(ERROR_CLASS);
    var predicate = self.filterElement.find(':input[name=predicate] option:selected').val();
    var predicateText = self.filterElement.find(':input[name=predicate] option:selected').text();
    var label = value + self.unit;
    var isRangeQuery = this.filterElement.find("#maxValue").is(":visible");
    if(isRangeQuery){
      valueMax = inputMaxValue.val();
      label = value + self.unit + " and " +  valueMax + self.unit;
    }
    var rangeValue = null;
    if(predicate == 'bt') { // is between predicate
      rangeValue = predicatePatternMap[predicate].replace('%v1',value).replace('%v2',valueMax);
    } else {
      rangeValue = predicatePatternMap[predicate].replace('%v',value);
    }
    if(!self.isBlank(value) && !this.existsFilter({value: rangeValue})){            
      var key = null;
      //Auto-complete stores the selected key in "key" attribute
      if (inputMinValue.attr("key") !== undefined) {
        key = inputMinValue.attr("key"); 
      }
      if(self.isBlank(value) || (!self.isBlank(value) && !self.isValidNumber(value,false,null,null))){
        inputMinValue.addClass(ERROR_CLASS);
        return;
      } 
      
      if(isRangeQuery && (self.isBlank(valueMax) || (!self.isBlank(valueMax) && !self.isValidNumber(valueMax,false,null,null)))){
        inputMaxValue.addClass(ERROR_CLASS);
        return;
      } 
      var rangePattern = predicatePatternMap[predicate];      
      self.addFilter({label:predicateText + ' ' + label,value: rangeValue, key:key,paramName:self.getId(),submitted: false});
      self.showFilters();
      inputMinValue.val('');
      inputMaxValue.val('');
    }
  };      
  return InnerOccurrenceComparatorWidget;
})(jQuery,_,OccurrenceWidget);


/**
 * Comparator widget. Displays an selection list of available comparators (=,>,<) and an input box for the value.
 */
var OccurrenceDateComparatorWidget = (function ($,_,OccurrenceWidget) {
  
  var InnerOccurrenceDateComparatorWidget = function () {        
  }; 
  
  //Inherits everything from the OccurrenceWidget module.
  InnerOccurrenceDateComparatorWidget.prototype = $.extend(true,{}, new OccurrenceWidget());
  
  /**
   * Validates if the filter value exists for the input predicate.
   */
  InnerOccurrenceDateComparatorWidget.prototype.bindOnPredicateChange = function() {
    var self = this;
    //Creates the dropdowns for predicates selection
    self.filterElement.find(":input[name=predicate]").dropkick({
      change: function (value, label) {
        if(value == 'bt'){
          self.filterElement.find(".max_value_cfg").show();
          self.filterElement.find(".min_value_cfg").hide();
        } else {
          self.filterElement.find(".max_value_cfg").hide();
          self.filterElement.find(".min_value_cfg").show();
        }     
      }
     });
     
    //Creates the date formats dropdowns and datepickers
    self.filterElement.find(":input.date_format").dropkick({ 
      change: function() {
        var selectedViewMode = $(this).find(":selected").val();
        var datePicker = $(this).data("target");
        if(datePicker == "dateFrom"){
          self.bindDateFromControl(selectedViewMode);        
        } else {
          self.bindDateToControl(selectedViewMode);
        }      
      }
    });
    
    //Shows the date format configuration section
    self.filterElement.find(".configure_dates:first").click(function(e) {
      $('.datepicker').hide();
      e.preventDefault();
      self.filterElement.find(".date_fmt_cfg:first").show();      
      if(self.isRangeQuery()){
        self.filterElement.find(".max_value_cfg").show();
      } else {
        self.filterElement.find(".max_value_cfg").hide();
      }
    });
    //Closes the date format configuration sectio
    self.filterElement.find(".close_cfg:first").click(function(e) {
      e.preventDefault();
      self.filterElement.find(".date_fmt_cfg:first").hide();
    });
  };

  /**
   * Executes binding function bound during the object construction.
   */
  InnerOccurrenceDateComparatorWidget.prototype.executeAdditionalBindings = function() {      
    this.bindingsExecutor.call();       
    this.bindDateControls('months','months');
    this.bindAutoAddControl(this.filterElement.find(":input[name=" + this.getId() + "Max]"));
  };
  
  /**
   * Checks is the current filter is a range query.
   */
  InnerOccurrenceDateComparatorWidget.prototype.isRangeQuery = function() {
    return this.filterElement.find("#maxValue").is(":visible");
  }

  /**
   * The bindAddFilterControl function is re-defined to validate and process the coordinates. 
   */
  InnerOccurrenceDateComparatorWidget.prototype.addFilterControlEvent = function (self,input) {        
    //gets the value of the input field        
    var inputMinValue = this.filterElement.find("input[name=" + this.getId() + "]");
    var value = inputMinValue.val();     
    var valueMax = null;
    var inputMaxValue = this.filterElement.find("input[name=" + this.getId() + "Max]");
    inputMinValue.removeClass(ERROR_CLASS);
    inputMaxValue.removeClass(ERROR_CLASS);
    var predicate = self.filterElement.find(':input[name=predicate] option:selected').val();
    var predicateText = self.filterElement.find(':input[name=predicate] option:selected').text();
    var label = value;
    var isRangeQuery = this.filterElement.find("#maxValue").is(":visible");
    if(isRangeQuery){
      valueMax = inputMaxValue.val();
      label = value + " and " +  valueMax;
    }
    
    if(!this.validateDateInput(inputMinValue)){
      return;
    }
    var rangeValue = null;
    if(predicate == 'bt') { // is between predicate
      rangeValue = predicatePatternMap[predicate].replace('%v1',value).replace('%v2',valueMax);
    } else {
      rangeValue = predicatePatternMap[predicate].replace('%v',value);
    }
    if(!self.isBlank(value) && !this.existsFilter({value: rangeValue})){            
      var key = null;
      //Auto-complete stores the selected key in "key" attribute
      if (inputMinValue.attr("key") !== undefined) {
        key = inputMinValue.attr("key"); 
      }
      if(self.isBlank(value)){
        inputMinValue.addClass(ERROR_CLASS);
        return;
      } 
      
      if(isRangeQuery && (self.isBlank(valueMax) || !self.validateDateInput(inputMaxValue) || !self.isValidRange())) {        
        inputMaxValue.addClass(ERROR_CLASS);
        return;        
      } 
      
      var rangePattern = predicatePatternMap[predicate];      
      self.addFilter({label:predicateText + ' ' + label,value: rangeValue, key:key,paramName:self.getId(),submitted: false});
      self.showFilters();
      inputMinValue.val('');
      inputMaxValue.val('');
    }
  };     
  
  /**
   * Validates of the range date is valid.
   */
  InnerOccurrenceDateComparatorWidget.prototype.isValidRange = function() {
    return this.dateTo.date.valueOf() > this.dateFrom.date.valueOf();
  };
  
  /**
   * Gets the date format related to the viewMode parameter.
   */
  InnerOccurrenceDateComparatorWidget.prototype.getDateFormat = function(viewMode) {
    var defaultFormat = 'yyyy-mm'; 
    if (viewMode == 'months') {
      return defaultFormat;
    } else if (viewMode == 'days') {
      return 'yyyy-mm-dd';
    } else if (viewMode == 'years') {
      return 'yyyy';
    } else {
      return defaultFormat;
    }
  };
  
  
  /**
   * Gets the date format related to the viewMode parameter.
   */
  InnerOccurrenceDateComparatorWidget.prototype.setDateMask = function(viewMode, input) {
    var defaultFormat = {mask: '9999-99', placeholder: 'yyyy-mm'};    
    $(input).removeClass(ERROR_CLASS)
    if (viewMode == 'months') {
      $(input).inputmask(defaultFormat);
      $(input).data('date-mask','yyyy-mm');
      $(input).attr('placeholder','yyyy-mm');
    } else if (viewMode == 'days') {
      $(input).inputmask('yyyy-mm-dd');
      $(input).data('date-mask','yyyy-mm-dd');
      $(input).attr('placeholder','yyyy-mm-dd');
    } else if (viewMode == 'years') {
      $(input).inputmask({mask: '9999', placeholder: 'yyyy'});
      $(input).data('date-mask','yyyy');
      $(input).attr('placeholder','yyyy');
    } else {
      $(input).inputmask(defaultFormat);
      $(input).data('date-mask','yyyy-mm');
      $(input).attr('placeholder','yyyy-mm');
    }
  };
  
  /**
   * Validates the value of date input control.
   */
  InnerOccurrenceDateComparatorWidget.prototype.validateDateInput = function(input) { 
    var now = new Date();
    var mask = $(input).data('date-mask');
    if(mask == 'yyyy'){
      var yearValue = parseInt($(input).val());
      if (yearValue < 0 || yearValue > now.getFullYear()) {
        $(input).addClass(ERROR_CLASS);
        return false;
      }
    } else if(mask == 'yyyy-mm') {
      var spliDate = $(input).val().split("-");
      var yearValue = parseInt(spliDate[0]);
      if (yearValue < 0 || yearValue > now.getFullYear()) {
        $(input).addClass(ERROR_CLASS);
        return false;
      }
      var monthValue = parseInt(spliDate[1]);
      if (monthValue < 0 || monthValue > 12) {
        $(input).addClass(ERROR_CLASS);
        return false;
      }      
    }
    return true;
  };
  
  /**
   * Create datepickers components.
   */
  InnerOccurrenceDateComparatorWidget.prototype.bindDateControls = function(dateFromViewMode,dateToViewMode) {
    this.bindDateFromControl(dateFromViewMode);
    this.bindDateToControl(dateToViewMode)
    this.bindOnPredicateChange();
  };
  
  
  /**
   * Create datepickers components.
   */
  InnerOccurrenceDateComparatorWidget.prototype.bindDateToControl = function(dateToViewMode) {
    var nowTemp = new Date();
    var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
    var self = this;
    if (this.dateTo) {      
      this.dateTo.remove();
      $(self.filterElement.find(".max_value")[0]).val('');      
    }
    var maxDate = this.filterElement.find(".max_value");      
    self.setDateMask(dateToViewMode, maxDate);    
    var dateTo = maxDate.datepicker({format:self.getDateFormat(dateToViewMode),viewMode:dateToViewMode,minViewMode:dateToViewMode,endDate:now,
      onRender: function(date) {
        return self.dateFrom && date.valueOf() <= self.dateFrom.date.valueOf() ? 'disabled' : '';
      },
      keyboardNavigation: false
    }).on('changeDate', function(ev) {      
      var newDate = new Date(ev.date);
      newDate.setDate(newDate.getDate() - 1);                  
      self.dateFrom.setEndDate(newDate);      
      dateTo.hide();
    }).data('datepicker');
    $(maxDate).keypress(function(){
      dateTo.show();
    });
    this.dateTo = dateTo;
  };
  
  
  /**
   * Create datepickers components.
   */
  InnerOccurrenceDateComparatorWidget.prototype.bindDateFromControl = function(dateFromViewMode) {
    var nowTemp = new Date();
    var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
    var self = this;    
    if (this.dateFrom) {
      this.dateFrom.remove();
      $(self.filterElement.find(".min_value")[0]).val('');
    }    
    var minDate = this.filterElement.find(".min_value");
    self.setDateMask(dateFromViewMode,minDate);
    var dateFrom = minDate.datepicker({format:self.getDateFormat(dateFromViewMode),viewMode:dateFromViewMode,minViewMode:dateFromViewMode,endDate:now,
      onRender: function(date) {
        return date.valueOf() < now.valueOf() ? 'disabled' : '';
      },
      keyboardNavigation: false
    }).on('changeDate', function(ev) {
      if(this.dateTo){
        var newDate = new Date(ev.date);
        newDate.setDate(newDate.getDate() + 1);      
        self.dateTo.setStartDate(newDate);
      }
      dateFrom.hide();
      if(self.dateTo && self.isBlank($(self.filterElement.find(".max_value")[0]).val())) {
        self.filterElement.find(".max_value")[0].focus();
      }
    }).data('datepicker');
    
    $(minDate).keypress(function(){
      dateFrom.show();
    });
    this.dateFrom = dateFrom;    
  };
  
  return InnerOccurrenceDateComparatorWidget;
})(jQuery,_,OccurrenceWidget);


/**
 * Basis of Record widget. Displays a multi-select list with the basis of record values.
 */
var OccurrenceBasisOfRecordWidget = (function ($,_,OccurrenceWidget) {
  var InnerOccurrenceBasisOfRecordWidget = function () {        
  }; 
  //Inherits everything from OccurrenceWidget
  InnerOccurrenceBasisOfRecordWidget.prototype = $.extend(true,{}, new OccurrenceWidget());

  /**
   * Re-defines the showFilters function, iterates over the selection list to get the selected values and then show them as filters. 
   */
  InnerOccurrenceBasisOfRecordWidget.prototype.showFilters = function() {
    if(this.filterElement != null) {
      var self = this;
      this.filterElement.find(".basis-of-record > li").each( function() {
        $(this).removeClass("selected");
        for(var i=0; i < self.filters.length; i++) {
          if(self.filters[i].value == $(this).attr("key") && !$(this).hasClass("selected")) {
            $(this).addClass("selected");
          }
        }
      });
    }
  };   

  /**
   * Executes addtional bindings: binds click event of each basis of record element.
   */
  InnerOccurrenceBasisOfRecordWidget.prototype.executeAdditionalBindings = function(){
    if(this.filterElement != null) {
      var self = this;
      this.filterElement.find(".basis-of-record > li").click( function() {
        if ($(this).hasClass("selected")) {
          self.removeFilter({value:$(this).attr("key"),key:null});
          $(this).removeClass("selected");
        } else {
          self.addFilter({value:$(this).attr("key"),key:null,submitted: false,paramName:self.getId()});
          $(this).addClass("selected");
        }
      });
    }
  };
  return InnerOccurrenceBasisOfRecordWidget;
})(jQuery,_,OccurrenceWidget);

/**
 * Object that controls the creation and default behavior of OccurrenceWidget and OccurrenceFilterWidget instances.
 * Manage how each filter widget should be bound to a occurrence widget instance, additionally controls what occurrence parameter is mapped to an specific widget.
 * This object should be instantiated only once in a page (Singleton).
 * 
 */
var OccurrenceWidgetManager = (function ($,_) {

  //All the fields are singleton variables  
  var widgets;
  var targetUrl;
  var submitOnApply = false;

  //Holds the list of the configuration setting when the page in loaded
  var initialConfParams;

  /**
   * Gets a occurrence widget instance by its id field.
   */
  function getWidgetById(id) {
    var widgetId = id;
    if(widgetId == 'GEOREFERENCED' || widgetId == 'POLYGON' || widgetId == 'SPATIAL_ISSUES') { //GEOREFERENCED parameter is handled by BOUNDING_BOX widget
      widgetId = 'GEOMETRY';
    }
    for (var i=0;i < widgets.length;i++) {
      if(widgets[i].getId() == widgetId){ return widgets[i];}
    }
    return;
  };

  function buildOnSelectHandler(paramName,el){
    return function (newFilter) {        
      var widget = getWidgetById(paramName);
      widget.addFilter($.extend({},newFilter,{paramName:paramName,submitted: false}));            
      widget.showFilters();
      $(el).val('');        
    };
  };

  /**
   * Calculates visible position in the screen. The returned value of this function is used to display the "wait dialog" while a request is submitted to the server.
   */
  function getTopPosition(div) {
    return (( $(window).height() - div.height()) / 2) + $(window).scrollTop() - 50;
  };

  /**
   * Displays the "wait dialog" while a request is submitted to the server.
   */
  function showWaitDialog(){
    //Sets the position
    $('#waitDialog').css("top", getTopPosition($('#waitDialog')) + "px");
    //Shows the dialog
    $('#waitDialog').fadeIn("medium", function() { hidden = false; });
    //Append the dialog to the html.body
    $("body").append("<div id='lock_screen'></div>");
    //Locks the screen
    $("#lock_screen").height($(document).height());
    $("#lock_screen").fadeIn("slow");
  };  


  /**
   * Default constructor for the widget manager.
   */
  var InnerOccurrenceWidgetManager = function(targetUrlValue,filters,controlSelector,submitOnApplyParam){
    widgets = new Array();
    targetUrl = targetUrlValue;
    submitOnApply = submitOnApplyParam;
    this.bindToWidgetsControl(controlSelector);
    this.initialize(filters);    
  };

  InnerOccurrenceWidgetManager.prototype = {                 

      //Constructor
      constructor : InnerOccurrenceWidgetManager,           

      /**
       * Gets the list of widgets.
       */
      getWidgets : function(){ return widgets;},

      /**
       * Binds the filter rendering to a click event of HTML element.
       * Creates an occurrence widgets depending of its names, for example: if the paramater name "DATE" exists an OccurrenceMonthWidget instance is created.
       */
      bindToWidgetsControl : function(element) {
        var self = this;
        var widgetContainer = $("tr.header");
        this.targetUrl = targetUrl;
        //Iterates over all elements with class 'filter-control' in the current page
        $(element).find('.filter-control').each( function(idx,control) {
          //By examinig the attribute data-filter creates the corresponding OccurreWidget(or subtype) instance.
          //Also the binding function is set as parameter, for instance: elf.bindSpeciesAutosuggest. When a binding function isn't needed a empty function is set:  function(){}.
          var filterName = $(control).attr("data-filter");
          if (filterName != "GEOREFERENCED") { //these filters are skiped because use the same widget as the bounding box widget
            var newWidget;
            if (filterName == "TAXON_KEY") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindSpeciesAutosuggest});
            } else if (filterName == "DATASET_KEY") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindDatasetAutosuggest});            
            } else if (filterName == "COLLECTOR_NAME") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindCollectorNameAutosuggest});            
            } else if (filterName == "CATALOG_NUMBER") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindCatalogNumberAutosuggest});            
            } else if (filterName == "COLLECTION_CODE") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindCollectionCodeAutosuggest});            
            } else if (filterName == "INSTITUTION_CODE") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindInstitutionCodeAutosuggest});            
            } else if (filterName == "GEOMETRY") {
              newWidget = new OccurrenceLocationWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindMap});            
            } else if (filterName == "DATE" || filterName == "MODIFIED") {
              newWidget = new OccurrenceDateComparatorWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: function(){}});            
            } else if (filterName == "MONTH") {
              newWidget = new OccurrenceMonthWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: function(){}});            
            } else if (filterName == "BASIS_OF_RECORD") {
              newWidget = new OccurrenceBasisOfRecordWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: function(){}});              
            } else if (filterName == "COUNTRY" || filterName == "PUBLISHING_COUNTRY") {
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: self.bindCountryAutosuggest});              
            } else if (filterName == "ALTITUDE" || filterName == "DEPTH" | filterName == "YEAR") {
              newWidget = new OccurrenceComparatorWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: function(){}});        
              newWidget.setUnit("m");
            } else { //By default creates a simple OccurrenceWidget with an empty binding function
              newWidget = new OccurrenceWidget();
              newWidget.init({widgetContainer: widgetContainer,manager: self,bindingsExecutor: function(){}});                      
            }
            newWidget.bindToControl(control);
            widgets.push(newWidget);
          }
        });       
      },

      /**
       * Handles the click event to positioning the dropdown menus relative to the element that shows them.
       */
      centerDropDownMenus: function() {
        $('a.[data-toggle="dropdown"]').click( function(e){                    
          // .position() uses position relative to the offset parent, 
          var pos = $(this).position();

          var height = $(this).outerHeight();

          // .outerWidth() takes into account border and padding.
          var width = $(this).outerWidth();          

          //show the menu directly over the placeholder
          $('div.dropdown-menu').css({
            position: "absolute",
            top: (pos.top + height) + "px",
            left: (pos.left - (width/2)) + "px",
            right: width + "px"
          });
        });
      }, 

      /**
       * Binds the configure widget.
       */
      bindConfigureWidget: function() {
        var self = this; 

        //Apply the configuration settings
        $('div.configure > div.buttonContainer > #applyConfiguration.button').click( function(){
          $(this).parent().parent().hide();
          self.submit(self.getConfigurationParams());
        });

        // prevents the dropdown menu to be closed by the boostrap.min.js script
        $('div.configure').click( function(e) {           
          e.stopPropagation();          
        });

        //Ensures that the default values are set everytime the div is shown
        $('a.configure').click( function(e) {
          self.setPredefinedCheckboxesValues('occurrence_columns','columns');
          self.setPredefinedCheckboxesValues('summary_fields','summary');
        });

        //Ensures that at least 1 checkbox of summary fields exists
        $('#summary_fields li :checkbox').click( function(e){
          if($("#summary_fields li :checkbox[checked]").size() == 0){
            e.preventDefault();
          }
        });
      },

      /**
       * Utility function to set the checkboxes state using the default configuration settings.
       */
      setPredefinedCheckboxesValues: function(containerId,attribute) {
        if (initialConfParams[attribute]) {
          $('#'+ containerId + ' > li > :checkbox').each(function(idx,el){
            if($.inArray($(el).val(),initialConfParams[attribute]) > -1){
              $(this).attr('checked',true);
            } else {
              $(this).removeAttr('checked');
            }
          });
        }
      },

      /**
       * Iterates over the checkboxes to get the values for columns and summary fiels that must be displayed.
       */
      getConfigurationParams : function(){       
        var params = {};
        $('#occurrence_columns li :checkbox, #summary_fields li :checkbox').each(function(idx,el){
          if($(el).attr('checked')) {
            var paramName = $(el).attr('name');
            if (params[paramName] == null) {
              params[paramName] = new Array();
            }
            params[paramName].push($(el).val());
          }
        });
        return params;
      },

      /**
       * Binds the species auto-suggest widget used by the TAXON_KEY widget.
       */
      bindSpeciesAutosuggest: function(){
        $(':input.species_autosuggest').each( function(idx,el){
          $(el).speciesAutosuggest(cfg.wsClbSuggest, SUGGEST_LIMIT, "#nubTaxonomyKey[value]", "#content",buildOnSelectHandler('TAXON_KEY',el));
        });   
      },

      /**
       * Binds the species auto-suggest widget used by the COUNTRY widget.
       */
      bindCountryAutosuggest: function(){        
        var self = this;
        $(':text[name="COUNTRY"]').each( function(idx,el){
          $(el).countryAutosuggest(countryList,"#content",buildOnSelectHandler('COUNTRY',el));
        });  
        $(':text[name="PUBLISHING_COUNTRY"]').each( function(idx,el){
          $(el).countryAutosuggest(countryList,"#content",buildOnSelectHandler('PUBLISHING_COUNTRY',el));
        });  
      },

      /**
       * Binds the dataset title auto-suggest widget used by the DATASET_KEY widget.
       */
      bindDatasetAutosuggest: function(){        
        $(':input.dataset_autosuggest').each( function(idx,el){
          $(el).datasetAutosuggest(cfg.wsRegSuggest, SUGGEST_LIMIT, 70, "#content", buildOnSelectHandler('DATASET_KEY',el),'OCCURRENCE');
        });   
      },

      /**
       * Binds the collector name  auto-suggest widget used by the COLLECTOR_NAME widget.
       */
      bindCollectorNameAutosuggest : function(){        
        $(':input.collector_name_autosuggest').each( function(idx,el){
          $(el).termsAutosuggest(cfg.wsOccCollectorNameSearch, "#content",SUGGEST_LIMIT,buildOnSelectHandler('COLLECTOR_NAME',el));
        });        
      },

      /**
       * Binds the catalog number  auto-suggest widget used by the CATALOG_NUMBER widget.
       */
      bindCatalogNumberAutosuggest : function(){                
        $(':input.catalog_number_autosuggest').each( function(idx,el){
          $(el).termsAutosuggest(cfg.wsOccCatalogNumberSearch, "#content",SUGGEST_LIMIT, buildOnSelectHandler('CATALOG_NUMBER',el));
        });
      },  

      /**
       * Binds the catalog number  auto-suggest widget used by the INSTITUTION_CODE widget.
       */
      bindInstitutionCodeAutosuggest : function(){                
        $(':input.institution_code_autosuggest').each( function(idx,el){
          $(el).termsAutosuggest(cfg.wsOccInstitutionCodeSearch, "#content",SUGGEST_LIMIT, buildOnSelectHandler('INSTITUTION_CODE',el));
        });
      },  

      /**
       * Binds the catalog number  auto-suggest widget used by the CATALOG_NUMBER widget.
       */
      bindCollectionCodeAutosuggest : function(){                
        $(':input.collection_code_autosuggest').each( function(idx,el){
          $(el).termsAutosuggest(cfg.wsOccCollectionCodeSearch, "#content",SUGGEST_LIMIT, buildOnSelectHandler('COLLECTION_CODE',el));
        });
      },  

      /**
       * Binds the catalog number  auto-suggest widget used by the BBOX widget.
       */
      bindMap : function() {        
        var CONFIG = { // global config var
            minZoom: 0,
            maxZoom: 14,
            center: [0, 0],
            defaultZoom: 1
        };
        var   
        cmAttr = 'Nokia',  
        cmUrl  = 'http://2.maps.nlp.nokia.com/maptile/2.1/maptile/newest/normal.day.grey/{z}/{x}/{y}/256/png8?app_id=_peU-uCkp-j8ovkzFGNU&app_code=gBoUkAMoxoqIWfxWA5DuMQ';

        var    
        minimal   = L.tileLayer(cmUrl, {styleId: 997,   attribution: cmAttr});

        map = L.map('map', {
          center: CONFIG.center,
          zoom: CONFIG.defaultZoom,
          layers: [minimal],
          zoomControl: false
        });
        setupZoom(map);

        defaultMapLayer = new L.LayerGroup();
        map.addLayer(defaultMapLayer);
        var drawControl = new L.Control.Draw({
          position: 'topright',
          polygon: true,
          circle: false,
          marker:false,
          polyline:false
        });
        map.addControl(drawControl); 

        map.on('draw:rectangle-created', function (e) {                            
          defaultMapLayer.addLayer(e.rect);          
          var event = jQuery.Event("add_bounding_box");          
          event.map = map;
          event.mapLayer = defaultMapLayer;
          event.rect = e.rect;
          $(document).trigger(event);            
        }); 
        map.on('draw:poly-created', function (e) {                     
          var event = jQuery.Event("add_polygon");
          event.poly = e.poly;
          event.map = map;
          event.mapLayer = defaultMapLayer;
          $(document).trigger(event);          
        }); 
      },

      /**
       * Applies the selected filters by issuing a request to target url.
       */
      applyOccurrenceFilters : function(refreshFilters){        
        if (refreshFilters) {
          this.addFiltersFromWidgets();
        }
        //if this.submitOnApply the elements are not submitted
        if (submitOnApply) {        
          return this.submit({});
        }
      },    

      /**
       * Reads the filters on each widget and then creates the filter widgets.
       */
      addFiltersFromWidgets : function() {
        var filters = new Object();
        var i = widgets.length - 1;
        while (i >= 0) {
          var appliedFilters = widgets[i].getFilters();
          var filters_idx =  appliedFilters.length - 1;
          while (filters_idx >= 0) {
            if(filters[widgets[i].getId()] == undefined){
              filters[widgets[i].getId()] = new Array();
            }
            filters[widgets[i].getId()].push(appliedFilters[filters_idx]);
            filters_idx=filters_idx-1;
          }
          widgets[i].close();
          i=i-1;
        }
        this.initialize(filters);
      },
      /**
       * Submits a GET request
       */
      submit : function(additionalParams, submitTargetUrl){
        this.submit(additionalParams,submitTargetUrl,false);
      },
      /**
       * Submits the request using the selected filters.
       */
      submit : function(additionalParams, submitTargetUrl, isPost) {
        submitTargetUrl = submitTargetUrl || targetUrl;
        showWaitDialog();
        var params = $.extend({},additionalParams);               

        //Collect the filter values
        for(var wi=0; wi < widgets.length; wi++) {
          var widgetFilters = widgets[wi].getFilters();
          for (var fi=0; fi < widgetFilters.length; fi++) {
            var filter = widgetFilters[fi];
            var paramName = filter.paramName;
            if (undefined == paramName){              
              paramName = widgets[wi].getId();
            }            
            if (params[paramName] == null) {
              params[paramName] = new Array();
            }
            if (filter.key != null) {
              //key field could be a string or a number, but is sent as a string
              if($.type(filter.key) == 'string' && filter.key.length > 0){
                params[paramName].push(filter.key);
              } else if ($.type(filter.key) == 'number'){
                params[paramName].push(filter.key.toString());
              }
            } else {
              params[paramName].push(filter.value);              
            }                      
          }          
        }       
        //redirects the window to the target
        if (isPost) {
          var formStr = '<form action="' + submitTargetUrl + '" method="post">';
          $.each(params, function(param,values) {
            if($.isArray(values)){
              $.each(values, function(index,value) {
                formStr += '<input type="text" name="'+ param + '" value="' + value + '" />';
              });
            } else {
              formStr += '<input type="text" name="'+ param + '" value="' + values+ '" />';
            }
          });                          
          formStr += '</form>';
          var objForm = $(formStr);
          $('body').append(objForm);
          $(objForm).submit();          
        } else {
          window.location = submitTargetUrl + $.param(params,true);
        }
        return true;  // submit?
      },

      /**
       * Iterates over all the "filter widgets" and executes on each one the init() function.
       */
      initWidgets : function(){
        for(var i=0; i < widgets.length; i++){          
          widgets[i].showSummaryView();          
        }
      },
      
      /**
       * Using a polygon parameter value, creates a polygon shape.
       */
      createPolygon : function(coords){
        var pointsList = coords.split(',');
        var points = new Array();
        var popupLabel = "";
        for(var i = 0; i < pointsList.length - 1; i++) {
          var latLng = pointsList[i].split(' ');
          points.push(new L.LatLng(latLng[1],latLng[0]));
          popupLabel += latLng[1] + " " + latLng[0];
          if(i < pointsList.length - 2){
            popupLabel +=  ",";
          }
        }
        var polygon = new L.Polygon(points,DEFAULT_SHAPE_OPTIONS);
        polygon.bindPopup('Polygon: ' + popupLabel);
        defaultMapLayer.addLayer(polygon);
        return polygon;
      },
      
      /**
       * Using a bounding box parameter value, creates a rectangle shape.
       */
      createRectangle : function(bbox){
        var coords = bbox.split(",");
        var southMost = coords[1].split(" ");
        var northMost = coords[3].split(" ");
        var bounds = new L.LatLngBounds(new L.LatLng(southMost[1],southMost[0]), new L.LatLng(northMost[1],northMost[0]));
        var rectangle = new L.Rectangle(bounds,DEFAULT_SHAPE_OPTIONS);
        rectangle.bindPopup("Bounding box: from " + southMost[1] + ","  + southMost[0] + " to " + northMost[1] + "," +  northMost[0]);
        defaultMapLayer.addLayer(rectangle);
        return rectangle;
      },
      
      /**
       * Checks if the list of coordinates forms a bounding box.
       */
      isRectangle: function(value){        
        var values = value.split(",");
        if(values.length == 5) {
          var point1 = values[0].split(" ");
          var point2 = values[1].split(" ");
          var point3 = values[2].split(" ");
          var point4 = values[3].split(" ");
          var valX1 = parseFloat(point1[0]) + parseFloat(point3[0]);                    
          var valX2 = parseFloat(point2[0]) + parseFloat(point4[0]);
          
          var valY1 = parseFloat(point1[1]) + parseFloat(point3[1]);
          var valY2 = parseFloat(point2[1]) + parseFloat(point4[1]);
          
          return (valX1 == valX2 && valY1  == valY2);
        }
        return false;
      },

      /**
       * Initializes the state of the module and renders the previously submitted filters.
       */
      initialize: function(filters){
        var self = this;  
        //The filters parameter could be null or undefined when none filter has been interpreted from the HTTP request 
        if(typeof(filters) != undefined && filters != null) {              
          $.each(filters, function(key,filterValues){
            $.each(filterValues, function(idx,filter) {                                  
              var occWidget = getWidgetById(filter.paramName);
              if (occWidget != undefined) { //If the parameter doesn't exist avoids the initialization                
                if(filter.paramName == 'GEOMETRY') {                                    
                  filter.value = filter.value.replace("POLYGON((","").replace("))","");
                  filter.label = filter.label.replace("POLYGON((","").replace("))","");
                  filter.marker = occWidget.getGeometries().length;
                  filter.key = null;
                  if(self.isRectangle(filter.value)) {
                    filter.targetParam = 'BOUNDING_BOX';
                    occWidget.addGeometry(self.createRectangle(filter.value));
                  } else {
                    filter.targetParam = 'POLYGON';
                    occWidget.addGeometry(self.createPolygon(filter.value));
                  }
                }
                occWidget.filters.push(filter);                    
              }
            });
          });
          this.initWidgets();
        }
        this.centerDropDownMenus();
        initialConfParams = this.getConfigurationParams();
        this.bindConfigureWidget();            
      }
  }
  return InnerOccurrenceWidgetManager;
})(jQuery,_);

