$(function() {

  // HEADER MENU
  var $nav = $("header #top nav");

  $nav.find("> ul div").on("mouseleave", function() {
    $(this).hide();
    $(this).parent().removeClass("selected");
  });

  $nav.find("> ul > li > a").on("mouseenter", function() {

    $(this).parent().addClass("selected");
    var $div = $(this).parent().find("div");
    $div.show();

    $nav.find("> ul div").each(function(i, e) {

      if ($(e).attr("class") != $div.attr("class")) {
        $(e).hide();
        $(e).parent().removeClass("selected");
      }
    });
  });

})
