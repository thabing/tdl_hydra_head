function toggleDisplay(imgName, firstRow, lastRow) {
  var img = $(imgName);
  var rows = $("#theTable tr");
  var display = (img.attr('src').indexOf("button_expand.png") != -1);
  var imgSrc = (display ? "/assets/img/button_collapse.png" : "/assets/img/button_expand.png");
  var rowDisplay = (display ? "" : "none");
  var rowIndex;

  img.attr('src', imgSrc);

  for (rowIndex = firstRow; rowIndex <= lastRow; rowIndex++) {
    var row = $(rows[rowIndex]);

    row.css('display', rowDisplay);
  }
}

function displayAll(display) {
  var rows = $("#theTable tr");
  var imgSrc = (display ? "/assets/img/button_collapse.png" : "/assets/img/button_expand.png");
  var rowDisplay = (display ? "" : "none");
  var rowIndex;
  var rowCount = rows.length;

  for (rowIndex = 0; rowIndex < rowCount; rowIndex++) {
    var row = $(rows[rowIndex]);
    var className = row.attr('class');

    if (className == "table_options" || className == "table_header") {
      // do nothing
    } else if (className == "folderRow") {
      row.find('.folderRowToggler').attr('src', imgSrc);
    } else {
      row.css('display', rowDisplay);
    }
  }
}

$(document).ready(function(){
  displayAll(false);
});
