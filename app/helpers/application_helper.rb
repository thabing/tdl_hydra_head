module ApplicationHelper

  #copied these two methods from generic_content_objects_helper.rb


  def disseminator_link(pid, datastream_name)
    return raw("<a class=\"fbImage\" href=\"#{ datastream_disseminator_url(pid, datastream_name) }\">view</a>")
  end


  def datastream_disseminator_url(pid, datastream_name)
    begin
      base_url = Fedora::Repository.instance.send(:connection).site.to_s
    rescue
      base_url = "http://localhost:8983/fedora"
    end

    return raw("#{base_url}/get/#{pid}/#{datastream_name}")
  end


  def get_google_docs_iframe(pid, datastream_name)
    return raw("<iframe src=\"http://docs.google.com/viewer?url=http://dl.dropbox.com/u/43822/tufts-UA005.036.001.00001.pdf&embedded=true\" width=\"600\" height=\"780\" style=\"border: none;\"></iframe>")
  end


  def showMetadataItem(label, tagID, metadataKey)
    return showMetadataItemForDatastream("DCA-META", label, tagID, metadataKey)
  end


  def showMetadataItemForDatastream(datastream, label, tagID, metadataKey)
#   result = "<iframe src="\" + datastream_disseminator_url(params[:id], datastream) + "\" width=\"600\" height=\"480\" style=\"border: none;\"></iframe>"
    result = ""

    unless get_values_from_datastream(@document_fedora, datastream, [metadataKey]).first.empty?

      result += "<div class=\"metadata_row\" id=\"" + tagID + "\"><div class=\"metadata_label\">" + label + "</div><div class=\"metadata_values\">"

      get_values_from_datastream(@document_fedora, datastream, [metadataKey]).each do |metadataItem|
        result += "<div class=\"metadata_value\">" + Sanitize.clean(RedCloth.new(metadataItem, [:sanitize_html]).to_html) + "</div>"
      end

      result += "</div></div>"
    end

    return raw(result)
  end


  def showImage(pid)
    result = "<img src=\"" + file_asset_path(pid) + "\"/>"

    return raw(result)
  end


  def render_image_viewer_link(pid)
      result = "<a href=\"" + imageviewer_path(pid) +"#page/1/mode/1up" + "\">full view</a>"

      return raw(result)
    end


 #http://ap.rubyonrails.org/classes/ActionController/Streaming.html#M000045
  def showGenericObjects(pid)
    blah = get_values_from_datastream(@document_fedora,"GENERIC-CONTENT",[:item])
    result = ""
    blah.each_with_index do |page, index|
      result+="<tr class=\"manifestRow\">"
      fileName = get_values_from_datastream(@document_fedora,"GENERIC-CONTENT",[:item,:fileName])[index];
      link = bucketproxy_path(pid,index);
      mimeType = get_values_from_datastream(@document_fedora,"GENERIC-CONTENT",[:item,:mimeType])[index];
      result+="<td class=\"nameCol\"><a class=\"manifestLink\" href=\"#{link}\">#{fileName}</a></td>"
      result+="<td class=\"mimeCol\">#{mimeType}</td>"
      result+="</tr>"
    end
    return raw(result)
  end


  def showPDFLink(pid)
    result = "<a href=\"" + file_asset_path(pid) + "\">Get PDF</a>"

    return raw(result)
  end


  def showHTML(pid)
    result = ActiveFedora::Base.load_instance(pid).datastreams_in_memory["Content.html"].content

    return raw(result)
  end


  def showAudioPlayer(pid)

    result = "<div id=\"playerDiv\"><div id=\"controls\"></div><ul id=\"playlist\"><li>"

#   the following line is what we would ultimately want but it doesn't work yet
#   result += "<a href=\"" + file_asset_path(pid) + "\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

#   the following line works in Safari and Firefox but not in Chrome or Opera
#   result += "<a href=\"" + datastream_disseminator_url(params[:id], "ACCESS_MP3") + "\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

#   the following line works in Safari, Chrome and Firefox but not in Opera
    result += "<a href=\"http://127.0.0.1:8983/fedora/get/" + pid + "/ACCESS_MP3\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

#   the following test works in Safari, Chrome, Firefox and Opera, proving that Opera is capable of using the yahoo media player, as in current DL prod...
#   result += "<a href=\"http://dl.tufts.edu/ProxyServlet/?url=http://repository01.lib.tufts.edu:8080/fedora/get/tufts:AC00001/bdef:TuftsAudio/getAudioFile&filename=tufts:AC00001.mp3\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

    result += "</li></ul></div>"

    return raw(result)
  end


  def showFeedbackForm(pid)
    result =  "<form id=\"feedbackForm\" action=\"/feedback\" method=\"post\">\n"

    result += "<div class=\"metadata_row\" id=\"feedbackBodyRow\"><label for=\"feedbackBody\" class=\"metadata_label\">Feedback</label><div class=\"metadata_values\">\n"
    result += "<div class=\"metadata_value\"><textarea id=\"feedbackBody\" name=\"feedbackBody\" rows=\"5\" tabindex=\"1\" aria-required=\"true\"></textarea></div>\n"
    result += "</div></div>\n"

    result += "<div class=\"metadata_row\" id=\"feedbackEmailRow\"><label for=\"feedbackEmail\" class=\"metadata_label\">Email address (optional)</label><div class=\"metadata_values\">\n"
    result += "<div class=\"metadata_value\"><textarea id=\"feedbackEmail\" name=\"feedbackEmail\" rows=\"1\" tabindex=\"2\" aria-required=\"true\"></textarea></div>\n"
    result += "</div></div>\n"

    result += "<div class=\"metadata_row\" id=\"feedbackSubmitRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
    result += "<div class=\"metadata_value\"><input type=\"submit\" id=\"feedbackSendButton\" name=\"feedbackSendButton\" value=\"Send Feedback\" tabindex=\"3\"/></div>\n"
    result += "</div></div>\n"

    result += "<div class=\"metadata_row\" id=\"feedbackHideRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
    result += "<div class=\"metadata_value\"><input type=\"button\" class=\"feedbackLink\" value=\"close feedback form\" onclick=\"hideFeedbackForm()\"/></div>\n"
    result += "</div></div>\n"

    result += "<div class=\"metadata_row\" id=\"feedbackShowRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
    result += "<div class=\"metadata_value\"><input type=\"button\" id=\"feedbackShowButton\" class=\"feedbackLink\" value=\"Have feedback?  Contact us.\" onclick=\"showFeedbackForm()\"/></div>\n"
    result += "</div></div>\n"

    result += "<noscript class=\"metadata_row\" id=\"feedbackNoScriptShowRow\"><div class=\"metadata_label\"></div><div class=\"metadata_values\">\n"
    result += "<div class=\"metadata_value\"><input type=\"submit\" id=\"feedbackNoScriptShowButton\" class=\"feedbackLink\" value=\"Have feedback?  Contact us.\"/></div>\n"
    result += "</div></noscript>\n"

    result += "</form>"

    return raw(result)
  end


  def showTranscriptFromDatastream(datastream)
    result =  "<div class=\"participant_section\">\n"
    result += "  <h1 class=\"participant_header\">Interview Participants</h1>\n"
    result += "  <div class=\"participant_table\">\n";

    id_attrs = get_values_from_datastream(@document_fedora, datastream, [:id_attr])
    participants = get_values_from_datastream(@document_fedora, datastream, [:p])
    role_attrs = get_values_from_datastream(@document_fedora, datastream, [:role_attr])

    index = 0;
    count = id_attrs.size

    while index < count
      result += "    <div class=\"participant_row\" id=\"participant" + (index + 1).to_s + "\">\n";
      result += "      <div class=\"participant_id\">" + Sanitize.clean(RedCloth.new(id_attrs[index], [:sanitize_html]).to_html) + ":</div>\n"
      result += "      <div class=\"participant_name\">" + Sanitize.clean(RedCloth.new(participants[index], [:sanitize_html]).to_html) + "</div>\n"
      result += "      <div class=\"participant_role\">" + Sanitize.clean(RedCloth.new(role_attrs[index], [:sanitize_html]).to_html) + "</div>\n"
      result += "    </div> <!-- participant_row -->\n"

      index += 1
    end

    result += "  </div> <!-- participant_table -->\n"
    result += "</div> <!-- participant_section -->\n"
    result += "<div class=\"transcript_section\">\n"
    result += "  <h1 class=\"transcript_header\">Transcript</h1>\n"
    result += "  <div class=\"transcript_table\">\n";

    speakers = get_values_from_datastream(@document_fedora, datastream, [:who_attr])
    utterances = get_values_from_datastream(@document_fedora, datastream, [:u_inner])

    index = 0;
    count = speakers.size

    while index < count
      result += "    <div class=\"transcript_row\" id=\"utterance" + (index + 1).to_s + "\">\n"
      result += "      <div class=\"transcript_speaker\">" + Sanitize.clean(RedCloth.new(speakers[index], [:sanitize_html]).to_html) + ":</div>\n"
      result += "      <div class=\"transcript_utterance\">" + Sanitize.clean(RedCloth.new(utterances[index], [:sanitize_html]).to_html) + "</div>\n"
      result += "    </div> <!-- transcript_row -->\n"

      index += 1
    end

    result += "  </div> <!-- transcript_table -->\n"
    result += "</div> <!-- transcript_section -->\n"

    return raw(result)
  end
  def render_back_to_overview_link
      link_to('Back to overview', catalog_url)

  end
end
