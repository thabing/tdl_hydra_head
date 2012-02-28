module ApplicationHelper

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
    #result += "<a href=\"http://127.0.0.1:8983/fedora/get/" + pid + "/ACCESS_MP3\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"
    result += "<a href=\"/file_assets/" + pid +"\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"
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
    result += "            <h1 class=\"participant_header\">Interview Participants</h1>\n"
    result += "            <div class=\"participant_table\">\n"

    participant_number = 0
    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:participants)

    node_sets.each do |node|
      node.children.each do |child|
        unless child.attributes.empty?
          participant_number += 1
          id = child.attributes["id"]
          role = child.attributes["role"]
          sex = child.attributes["sex"]
          result += "              <div class=\"participant_row\" id=\"participant" + participant_number.to_s + "\">\n"
          result += "                <div class=\"participant_id\">" + (id.nil? ? "" : id) + ":</div>\n"
          result += "                <div class=\"participant_name\">" + child.text + "</div>\n"
          result += "                <div class=\"participant_role\">" + (role.nil? ? "" : role) + "</div>\n"
          result += "                <div class=\"participant_sex\">" + (sex.nil? ? "" : sex) + "</div>\n"
          result += "              </div> <!-- participant_row -->\n"
        end
      end
    end

    result += "            </div> <!-- participant_table -->\n"
    result += "          </div> <!-- participant_section -->\n"

    timepoints = Hash.new
    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:when)

    node_sets.each do |node|
      timepoint_id = node.attributes["id"]
      timepoint_interval = node.attributes["interval"]
      unless timepoint_id.nil? || timepoint_interval.nil?
        timepoint_id = timepoint_id.value
        timepoint_interval = timepoint_interval.value
        # result += "<!-- " + timepoint_id + " => " + timepoint_interval + " -->\n"
        timepoints[timepoint_id] = timepoint_interval
      end
    end

    result += "          <div class=\"transcript_section\">\n"
    result += "            <h1 class=\"transcript_header\">Transcript</h1>\n"
    result += "            <div class=\"transcript_table\">\n"

    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:u)

    node_sets.each do |node|
      string_total_seconds = ""
      timepoint_id = node.attributes["start"]
      unless timepoint_id.nil?
        timepoint_id = timepoint_id.value
        timepoint_interval = timepoints[timepoint_id]
        unless timepoint_interval.nil?
          # timepoint_interval is a String containing the timestamp in milliseconds
          string_milliseconds = timepoint_interval
          int_total_seconds = timepoint_interval.to_i / 1000 # truncated to the second
          int_minutes = int_total_seconds / 60
          int_just_seconds = int_total_seconds - (int_minutes * 60) # the seconds for seconds:minutes (0:00) display
          string_total_seconds = int_total_seconds.to_s
          string_minutes = int_minutes.to_s
          string_just_seconds = int_just_seconds.to_s
          if (int_just_seconds < 10)
              string_just_seconds = "0" + string_just_seconds
          end
        end
      end
      result += "              <div class=\"transcript_chunk\" id=\"chunk" + string_total_seconds + "\">\n"
      unless (string_total_seconds == "")
        result += "                <div class=\"transcript_row\">\n"
        result += "                  <div class=\"transcript_speaker\"></div>\n"
        result += "                  <div class=\"transcript_utterance\">\n"
        result += "                    <a class=\"transcript_chunk_link\" href=\"javascript:YAHOO.MediaPlayer.play(thisMediaObj," + string_milliseconds + ");\">" + string_minutes + ":" + string_just_seconds + "</a>\n"
        result += "                  </div> <!-- transcript_utterance -->\n"
        result += "                </div> <!-- transcript_row -->\n"
      end
      node.children.each do |child|
        childName = child.name
        if (childName == "u")
          unless child.attributes.empty?
            who = child.attributes["who"]
            result += "                <div class=\"transcript_row\">\n"
            result += "                  <div class=\"transcript_speaker\">"+ (who.nil? ? "" : who.value) + "</div>\n"
            result += "                  <div class=\"transcript_utterance\">"+ parseNotations(child) + "</div>\n"
            result += "                </div> <!-- transcript_row -->\n"
          end
        elsif (childName == "event" || childName == "gap" || childName == "vocal")
          unless child.attributes.empty?
            desc = child.attributes["desc"]
            unless desc.nil?
              result += "                <div class=\"transcript_row\">\n"
              result += "                  <div class=\"transcript_speaker\">""</div>\n"
              result += "                  <div class=\"transcript_utterance\"><span class = \"transcript_notation\">["+ desc + "]</span></div>\n"
              result += "                </div> <!-- transcript_row -->\n"
            end
          end
        end
      end
      result += "              </div> <!-- transcript_chunk -->\n"
    end

    result += "            </div> <!-- transcript_table -->\n"
    result += "          </div> <!-- transcript_section -->"

    return raw(result)
  end


  def parseNotations(node)
    result = ""

    node.children.each do |child|
      childName = child.name

      if (childName == "text")
        result += child.text
      elsif (childName == "unclear")
        result += "<span class=\"transcript_notation\">[" + child.text + "]</span>"
      elsif (childName == "event" || childName == "gap" || childName == "vocal")
        unless child.attributes.empty?
          desc = child.attributes["desc"]
          unless desc.nil?
            result += "<span class=\"transcript_notation\">[" + desc + "]</span>"
          end
        end
      end
    end

    return raw(result)
  end


  def render_back_to_overview_link
      link_to('Back to overview', catalog_url)

  end
end
