// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .

// sandbox disable popups
if (window.self !== window.top && window.name!="view1") {;
  window.alert = function(){/*disable alert*/};
  window.confirm = function(){/*disable confirm*/};
  window.prompt = function(){/*disable prompt*/};
  window.open = function(){/*disable open*/};
}

// prevent href=# click jump
document.addEventListener("DOMContentLoaded", function() {
  var links = document.getElementsByTagName("A");
  for(var i=0; i < links.length; i++) {
    if(links[i].href.indexOf('#')!=-1) {
      links[i].addEventListener("click", function(e) {
          if (this.hash) {
            if (this.hash=="#") {
              e.preventDefault();
              return false;
            }
            else {
              /*
              var el = document.getElementById(this.hash.replace(/#/, ""));
              if (el) {
                el.scrollIntoView(true);
              }
              */
            }
          }
          return false;
      })
    }
  }
}, false);
