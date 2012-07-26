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


function submitFeedback2(pid, form_authenticity_token) {
  var params,
      message = document.getElementById("inputComment").value,
      optionalEmail = document.getElementById("inputEmail").value;

  if (message == null || message.length == 0) {
    alert("Please enter a message.");
    return;
  }

  if (optionalEmail == null || optionalEmail.length == 0) {
    optionalEmail = "unknown@unknowable.com";	// feedback_controller.rb expects an email address -- make one up.
  } else {
    var regexp = new RegExp("\\w+@\\w+\\.\\w+");

    if (!optionalEmail.match(regexp)) {
      alert("Please enter a valid email address or leave the email address field blank.");
      return;
    }
  }

  params  = "name=Unknown";		// feedback_controller.rb expects a name -- make one up.
  params += "&email=" + optionalEmail;
  params += "&message=" + message;
  params += "&authenticity_token=" + form_authenticity_token;
  params += "&utf8=#x2713;";

  if (pid != null && pid != "") {
    params += "&pid=" + pid;
  }

  $.ajax({
    type: "POST",
    url: "/feedback",
    data: encodeURI(params)
  });

  $('#comment_modal').modal('hide')
}


function submitFeedback() {
    var params,
    	message = document.getElementById("feedbackBody").value,
        optionalEmail = document.getElementById("feedbackEmail").value;

    if (message == null || message.length == 0) {
		alert("Please enter a message.");
		return;
    }

	if (optionalEmail == null || optionalEmail.length == 0) {
		optionalEmail = "unknown@unknowable.com";	// feedback_controller.rb expects an email address -- make one up.
	} else {
		var regexp = new RegExp("\\w+@\\w+\\.\\w+");

		if (!optionalEmail.match(regexp)) {
			alert("Please enter a valid email address or leave the email address field blank.");
			return;
		}
	}

    params  = "name=Unknown";		// feedback_controller.rb expects a name -- make one up.
    params += "&email=" + optionalEmail;
    params += "&message=" + message;
    params += "&pid=" + document.getElementById("feedbackPid").value;
    params += "&authenticity_token=" + document.getElementById("feedbackToken").value;
    params += "&utf8=#x2713;";

    $.ajax({
        type: "POST",
        url: "/feedback",
        data: encodeURI(params)
    });

    hideFeedbackForm();

	document.getElementById("feedbackShowButton").value = "Thank you for your feedback;  it has been sent.  Have more feedback?  Contact us.";
}
