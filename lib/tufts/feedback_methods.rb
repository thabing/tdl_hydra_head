module Tufts
module FeedbackMethods
def show_feedback_form(pid)
   result =  "<form id=\"feedbackForm\" action=\"/feedback\" method=\"post\">\n"

   result << "<div class=\"metadata_row\" id=\"feedbackBodyRow\"><label for=\"feedbackBody\" class=\"metadata_label\">Feedback</label><div class=\"metadata_values\">\n"
   result << "<div class=\"metadata_value\"><textarea id=\"feedbackBody\" name=\"feedbackBody\" rows=\"5\" tabindex=\"1\" aria-required=\"true\"></textarea></div>\n"
   result << "</div></div>\n"

   result << "<div class=\"metadata_row\" id=\"feedbackEmailRow\"><label for=\"feedbackEmail\" class=\"metadata_label\">Email address (optional)</label><div class=\"metadata_values\">\n"
   result << "<div class=\"metadata_value\"><textarea id=\"feedbackEmail\" name=\"feedbackEmail\" rows=\"1\" tabindex=\"2\" aria-required=\"true\"></textarea></div>\n"
   result << "</div></div>\n"

   result << "<div class=\"metadata_row\" id=\"feedbackSubmitRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
   result << "<div class=\"metadata_value\"><input type=\"submit\" id=\"feedbackSendButton\" name=\"feedbackSendButton\" value=\"Send Feedback\" tabindex=\"3\"/></div>\n"
   result << "</div></div>\n"

   result << "<div class=\"metadata_row\" id=\"feedbackHideRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
   result << "<div class=\"metadata_value\"><input type=\"button\" class=\"feedbackLink\" value=\"close feedback form\" onclick=\"hideFeedbackForm()\"/></div>\n"
   result << "</div></div>\n"

   result << "<div class=\"metadata_row\" id=\"feedbackShowRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
   result << "<div class=\"metadata_value\"><input type=\"button\" id=\"feedbackShowButton\" class=\"feedbackLink\" value=\"Have feedback?  Contact us.\" onclick=\"showFeedbackForm()\"/></div>\n"
   result << "</div></div>\n"

   result << "<input id=\"feedbackToken\" name=\"feedbackToken\" type=\"hidden\" value=\"" + form_authenticity_token + "\" />\n"
   result << "<input id=\"feedbackPid\" name=\"feedbackPid\" type=\"hidden\" value=\"" + pid + "\" />\n"

   result << "<noscript class=\"metadata_row\" id=\"feedbackNoScriptShowRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
   result << "<div class=\"metadata_value\"><input type=\"submit\" id=\"feedbackNoScriptShowButton\" class=\"feedbackLink\" value=\"Have feedback?  Contact us.\"/></div>\n"
   result << "</div></noscript>\n"

   result << "</form>"

   return raw(result)
 end
end
  end
