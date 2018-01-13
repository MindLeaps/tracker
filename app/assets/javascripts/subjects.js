$(document).ready(function() {
  $('.new-skill-container').on('cocoon:after-insert', function(e, item) {
    componentHandler.upgradeAllRegistered();
  });
});
