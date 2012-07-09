function toggleDisplay(imgName, firstRow, lastRow) {
  var img = document.getElementById(imgName);
  var table = document.getElementById("theTable");
  var rows = table.rows;
  var display = (img.src.indexOf("button_expand.png") != -1);
  var imgSrc = (display ? "/assets/img/button_collapse.png" : "/assets/img/button_expand.png");
  var rowDisplay = (display ? "" : "none");
  var rowIndex;

  img.src = imgSrc;

  for (rowIndex = firstRow; rowIndex <= lastRow; rowIndex++) {
    rows[rowIndex].style.display = rowDisplay;
  }
}

function displayAll(display) {
  var table = document.getElementById("theTable");
  var rows = table.rows;
  var imgSrcCurrent = (display ? "button_expand.png" : "button_collapse.png");
  var imgSrc = (display ? "button_collapse.png" : "button_expand.png");
  var rowDisplay = (display ? "" : "none");
  var rowIndex;
  var rowCount = rows.length;

  for (rowIndex = 0; rowIndex < rowCount; rowIndex++) {
    var row = rows[rowIndex];

    if (row.className == "table_options" || row.className == "table_header") {
      // do nothing
    } else if (row.className == "folderRow") {
      var cellInnerHTML = row.cells[0].innerHTML;

      // This is super hacky:
      row.cells[0].innerHTML = cellInnerHTML.replace(imgSrcCurrent, imgSrc);
    } else {
      row.style.display = rowDisplay;
    }
  }
}

$(document).ready(function(){
  displayAll(false);
});
