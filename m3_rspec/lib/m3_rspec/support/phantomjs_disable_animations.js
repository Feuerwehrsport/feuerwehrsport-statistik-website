// disable_animations.js
var disableAnimationStyles = '-webkit-transition: none !important;' +
                             '-moz-transition: none !important;' +
                             '-ms-transition: none !important;' +
                             '-o-transition: none !important;' +
                             'transition: none !important;'

window.onload = function() {
  var animationStyles = document.createElement('style');
  animationStyles.type = 'text/css';
  animationStyles.innerHTML = '* {' + disableAnimationStyles + '}';
  document.head.appendChild(animationStyles);

  if (typeof $ == 'function') {
    $.fx.off = true;
    $('html').removeClass('turbolinks-progress-bar');
  }
};
