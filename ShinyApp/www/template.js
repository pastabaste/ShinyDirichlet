$(document).ready(function() {
    var $sidebar = $("#sidebar");
    var $main = $("#main");
    var $window = $(window);
    
    var offsetTop = $sidebar.offset().top;
    var windowHeight = $window.height();

    $window.scroll(function() {
        if ($(window).width() > 768) {
            if ($window.scrollTop() >= offsetTop && $sidebar.height() < windowHeight) {
                $sidebar.css({
                  position: "fixed",
                  top: "10px",
                  width: "30%"
                });
                $main.css({
                  marginLeft: "35%"
                });
              } else {
                $sidebar.css({
                  position: "",
                  top: "",
                  width: ""
                });
                $main.css({
                  marginLeft: ""
                });
              }
        }
    });

    $window.resize();
});



