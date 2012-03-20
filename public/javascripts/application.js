// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {

// store url for current page as global variable
current_page = document.location.href;

// apply selected states depending on current page
if (current_page.match(/catalog/)) {
$("ul#nav li:eq(0)").addClass('active');
} else if (current_page.match(/search/)) {
$("ul#navi li:eq(1)").addClass('active');
} else if (current_page.match(/about/)) {
$("ul#nav li:eq(2)").addClass('active');
} else if (current_page.match(/contact/)) {
$("ul#nav li:eq(4)").addClass('active');
} else { // don't mark any nav links as selected
$("ul#navigation li").removeClass('active');
};

});