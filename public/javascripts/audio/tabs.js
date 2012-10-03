$(document).ready(
  function() {
    // If javascript is enabled, make the tabs work with bootstrap's javascript by updating their
    // hrefs and setting their data-toggle attributes.  This will allow the tabs to work without
    // reloading the page (which is the default behavior in case javascript is disabled.)

    var tab1 = $("#tab1"),
        tab2 = $("#tab2");

    tab1.attr("href", "#1");
    tab2.attr("href", "#2");

    tab1.attr("data-toggle", "tab");
    tab2.attr("data-toggle", "tab");
  }
);


  function chooseTranscriptTab() {
    $("#tab2").click();
  }
