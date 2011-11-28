$(document).ready(
  function() {
    document.getElementById("feedbackForm").action="javascript:submitFeedback();";

    hideFeedbackForm();
  }
);


function showFeedbackForm() {
    document.getElementById("feedbackBodyRow").style.display = "table-row";
    document.getElementById("feedbackEmailRow").style.display = "table-row";
    document.getElementById("feedbackSubmitRow").style.display = "table-row";
    document.getElementById("feedbackHideRow").style.display = "table-row";
    document.getElementById("feedbackShowRow").style.display = "none";

    return false;
}


function hideFeedbackForm() {
    document.getElementById("feedbackBodyRow").style.display = "none";
    document.getElementById("feedbackEmailRow").style.display = "none";
    document.getElementById("feedbackSubmitRow").style.display = "none";
    document.getElementById("feedbackHideRow").style.display = "none";
    document.getElementById("feedbackShowRow").style.display = "table-row";

    document.getElementById("feedbackBodyRow").setAttribute("aria-live", "polite");
    document.getElementById("feedbackEmailRow").setAttribute("aria-live", "polite");

    document.getElementById("feedbackShowButton").value = "Have feedback?  Contact us.";

    return false;
}


function submitFeedback() {
    hideFeedbackForm();

    document.getElementById("feedbackShowButton").value = "Thank you for your feedback;  it has been sent.  Have more feedback?  Contact us.";
}