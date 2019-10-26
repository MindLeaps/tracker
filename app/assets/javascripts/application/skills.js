$(document).ready(function() {
  $('.new-grade-descriptor-container').on('cocoon:after-insert', function(e, item) {
    componentHandler.upgradeAllRegistered();
  });
});
