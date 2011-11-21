$(document).ready(
  function() {
    hideFeedbackForm();
  }
);


function showFeedbackForm() {
    document.getElementById("feedbackBodyRow").style.display = "";
    document.getElementById("feedbackEmailRow").style.display = "";
    document.getElementById("feedbackSubmitRow").style.display = "";
    document.getElementById("feedbackHideRow").style.display = "";
    document.getElementById("feedbackShowRow").style.display = "none";

    return false;
}


function hideFeedbackForm() {
    document.getElementById("feedbackBodyRow").style.display = "none";
    document.getElementById("feedbackEmailRow").style.display = "none";
    document.getElementById("feedbackSubmitRow").style.display = "none";
    document.getElementById("feedbackHideRow").style.display = "none";
    document.getElementById("feedbackShowRow").style.display = "";

    document.getElementById("feedbackBodyRow").setAttribute("aria-live", "polite");
    document.getElementById("feedbackEmailRow").setAttribute("aria-live", "polite");

    return false;
}
