$(function() {

  // Image loading
  $("img[data-load]").each(function(img) {

    var url = $(this).attr("data-load");
    $(this).attr("src", url);

    // hide the image by default, only show it on success
    $(this).hide();

    $(this).on('load', function( instance ) {
      $(this).fadeIn(250);
    });

    /*
     *  Uncomment the following line if you need to handle
     *  the error event:
     *
     *  $(this).on('error', function( instance ) { });
     *
    */

  });

  // Placeholders for old browsers
  if (!Modernizr.input.placeholder){ // placeholder fix
    $('[placeholder]').focus(function() {
      var input = $(this);
      if (input.val() == input.attr('placeholder')) {
        input.val('');
        input.removeClass('placeholder');
      }
    }).blur(function() {
      var input = $(this);
      if (input.val() == '' || input.val() == input.attr('placeholder')) {
        input.addClass('placeholder');
        input.val(input.attr('placeholder'));
      }
    }).blur();
  }

  // DROPDOWN

  $(".dropdown .title").on("click", function(e) {
    e.preventDefault();
    $(this).parent().toggleClass("selected");
  });

  // GRAPHS
  $("div.graph li a, div.bargraph li a").on("click", function(e) {
    e.preventDefault();
  });

  $("body.home nav").on("mouseleave", function(e) {
    e.preventDefault();
    e.stopPropagation();
    $("li.search form").animate({ width: 10, opacity: 0}, 250, function() {
      $("a[data-action='show-search']").fadeIn(150);
    });

  });

  $("body.home a[data-action='show-search']").on("mouseover", function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(this).fadeOut(150, function() {
      $(this).parent().find("form").animate({ width: 180, opacity: 1}, 250, function() {
        $(this).find("input").focus();
      });
    });

  });

  $('div.graph').each(function(index) {
    $(this).find('ul li .value').each(function(index) {
      var width = $(this).parents("div").attr("class").replace(/graph /, "");
      $(this).parent().css("width", width);
      var value = $(this).text();
      $(this).delay(index * 100).animate({ height: value }, 400, 'easeOutBounce');
      var label_y = $(this).parent().height() - value - 36;
      $(this).parent().find(".label").css("top", label_y);
      $(this).parent().append("<div class='value_label'>" + value + "</div")
      $(this).parent().find(".value_label").css("top", (label_y + 13));
    });
  });

  $('div.bargraph').each(function(index) {
    $(this).find('ul li .value').each(function(index) {
      var width = $(this).parents("div").attr("class").replace(/bargraph /, "");
      $(this).parent().css("width", width);
      var value = $(this).text();
      $(this).delay(index * 100).animate({ height: value }, 400, 'easeOutBounce');
      var label_y = $(this).parent().height() - value - 36;
      $(this).parent().find(".label").css("top", label_y);
      $(this).parent().append("<div class='value_label'>" + value + "</div")
      $(this).parent().find(".value_label").css("top", (label_y + 13));
    });
  });


  $('div.graph ul li a').click(function(e) {
    e.preventDefault();
  });

  // focus on form input element with class "focus"
  $('input.focus').focus();

  $(".selectbox").selectBox();

  // Activate source popovers
  $("a.sourcePopup").append('<img src="'+((cfg.context+"/img/icons/questionmark.png").replace("//", "/")) +'"/>').each(function(idx, obj){
    $(obj).sourcePopover({"title":$(obj).attr("title"),"message":$(obj).attr("data-message"),"remarks":$(obj).attr("data-remarks")});
  });

  // Activate help popovers
  $("a.helpPopup").prepend('<img src="'+((cfg.context+"/img/icons/info.png").replace("//", "/")) +'"/> ').each(function(idx, obj){
    $(obj).sourcePopover({"title":$(obj).attr("title"),"message":$(obj).attr("data-message"),"remarks":$(obj).attr("data-remarks")});
  });

  // Activate link popovers
  $("a.popover").each(function(idx, obj){
    $(obj).sourcePopover({"title":$(obj).attr("title"),"message":$(obj).parent().find(".message").html(),"remarks":$(obj).parent().find(".remarks").html()});
  });

  // Dropdown for the sorting options of the taxonomic explorer
  $('#tax_sort_ocurrences').dropdownPopover({
    options: {
      links: [
        { name: "Sort alphabetically",
          callback: function(e) {
            e.preventDefault();
            $("#taxonomy .sp").animate({opacity:0}, 500, function() {
              sortAlphabetically($("#taxonomy .sp ul:first"));
              $("#taxonomy .sp").animate({opacity:1}, 500);
            });
          },
          replaceWith:'Sort alphabetically<span class="more"></span>'
      },
      { name: "Sort by count",
        callback: function(e) {
          e.preventDefault();
          $("#taxonomy .sp").animate({opacity:0}, 500, function() {
            sortByCount($("#taxonomy .sp ul:first"));
            $("#taxonomy .sp").animate({opacity:1}, 500);
          });
        },
        replaceWith:'Sort by count<span class="more"></span>'
      }
      ]
    }
  });

  $('span.input_text input').focus(function() {
    $(this).parent().addClass("focus");
  });

  $('span.input_text input').focusout(function() {
    $(this).parent().removeClass("focus");
  });


  if ($("#holder").length) {
    dataHistory.initialize(generateRandomValues(365), {height: 180, processes: processes});
    dataHistory.show();
  }

  // wrapper to use for i18n in JQuery. See README file for how to use it.
  $i18nresources = $.getResourceBundle("resources");

  // checks every link withing class="verify" and hides the element in case the link cannot be accessed
  $(".verify").each(function(index) {
    var link = $(this).find('a').attr("href");
    var elem = $(this);
    $.ajax({
      async: true,
      url: link,
      error: function(jqXHR, textStatus, errorThrown){
        elem.hide();
      },
      success: function(){
      }
    });
  });

  // hide and make contact addresses toggable
  $(".contactName").next().hide();
  $(".contactName").click(function(e){
      $(this).next().slideToggle("fast");
  });
  // some contacts don't have a name, allow to also toggle by contact type
  $(".contactType").click(function(e){
      $(this).next().next().slideToggle("fast");
  });
  $(".showAllContacts").click(function(e){
      $(".contactName").next().slideToggle("fast");
  });

})
