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
    result += "  <h1 class=\"participant_header\">Interview Participants</h1>\n"
    result += "  <div class=\"participant_table\">\n"

    #id_attrs = get_values_from_datastream(@document_fedora, datastream, [:id_attr])
    #participants = get_values_from_datastream(@document_fedora, datastream, [:p])
    #role_attrs = get_values_from_datastream(@document_fedora, datastream, [:role_attr])
    #
    #index = 0;
    #count = id_attrs.size
    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:participants)
    node_sets.each_with_index do |node,index|
      node.children.each do |child|
        unless child.attributes.empty?
          id = child.attributes["id"]
          sex = child.attributes["sex"]
          role = child.attributes["role"]
          result += "    <div class=\"participant_row\" id=\"participant" + (index + 1).to_s + "\">\n"
          unless id.nil?
            result += "      <div class=\"participant_id\">" + id + ":</div>\n"
          end
          result += "      <div class=\"participant_name\">" + child.text + "</div>\n"
          result += "      <div class=\"participant_role\">" + role + "</div>\n"
          result += "      <div class=\"participant_sex\">" + sex + "</div>\n"
          result += "    </div> <!-- participant_row -->\n"
        end
      end
    end

    #while index < count
    ###  result += "    <div class=\"participant_row\" id=\"participant" + (index + 1).to_s + "\">\n"
      #result += "      <div class=\"participant_id\">" + id_attrs[index] + ":</div>\n"
      #result += "      <div class=\"participant_name\">" + participants[index] + "</div>\n"
      ##result += "      <div class=\"participant_role\">" + role_attrs[index] + "</div>\n"
      #result += "    </div> <!-- participant_row -->\n"

      #index += 1
    #end

    result += "  </div> <!-- participant_table -->\n"
    result += "</div> <!-- participant_section -->\n"
    result += "<div class=\"transcript_section\">\n"
    result += "  <h1 class=\"transcript_header\">Transcript</h1>\n"
    result += "  <div class=\"transcript_table\">\n"
    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:u)

    # => #<Nokogiri::XML::Element:0x83736db4 name="u" attributes=[#<Nokogiri::XML::Attr:0x83a3130c name="rend" value="transcript_chunk">, #<Nokogiri::XML::Attr:0x83a312e4 name="start" value="timepoint_1">, #<Nokogiri::XML::Attr:0x83a312d0 name="n" value="1">, #<Nokogiri::XML::Attr:0x83a312bc name="end" value="timepoint_2">] children=[#<Nokogiri::XML::Text:0x83a30768 "\n\t  ">, #<Nokogiri::XML::Element:0x83a30704 name="u" attributes=[#<Nokogiri::XML::Attr:0x83a30574 name="who" value="AE">] children=[#<Nokogiri::XML::Text:0x83a30088 "This is a test, this is a test. I'm just going to record, this is Adrienne Effron and I'm here with Ed Ciampa, did I say that right?">]>, #<Nokogiri::XML::Text:0x83a2fee4 "\n\t  ">, #<Nokogiri::XML::Element:0x83a2fe80 name="u" attributes=[#<Nokogiri::XML::Attr:0x83a2fcf0 name="who" value="EC">] children=[#<Nokogiri::XML::Text:0x83a2f804 "Right, Ed Chi-amp-pah. ">]>, #<Nokogiri::XML::Text:0x83a2f660 "\n\t  ">, #<Nokogiri::XML::Element:0x83a2f5e8 name="u" attributes=[#<Nokogiri::XML::Attr:0x83a2f458 name="who" value="AE">] children=[#<Nokogiri::XML::Text:0x83a2ef6c "Chi-amp-pah, sorry I said it wrong.">]>, #<Nokogiri::XML::Text:0x83a2edc8 "\n\t  ">, #<Nokogiri::XML::Element:0x83a2ed64 name="u" attributes=[#<Nokogiri::XML::Attr:0x83a2ebd4 name="who" value="EC">] children=[#<Nokogiri::XML::Text:0x83a2e6e8 "No.">]>, #<Nokogiri::XML::Text:0x83a2e544 "\n\t">]>
   node_sets.each_with_index do |node,index|
    node.children.each do |child|
      unless child.attributes.empty?
        who = child.attributes["who"]
        result += "    <div class=\"transcript_row\" id=\"utterance" + (index + 1).to_s + "\">\n"
        unless who.nil?
          result += "<div class=\"transcript_speaker\">"+ who.value + "</div>"
        end
        result += "<div class=\"transcript_utterance\">"+ child.text() + "</div>"
        result += "    </div> <!-- transcript_row -->\n"
      end
    end
   end

  result += "  </div> <!-- transcript_table -->\n"
  result += "</div> <!-- transcript_section -->\n"

    return raw(result)
  end
  def render_back_to_overview_link
      link_to('Back to overview', catalog_url)

  end
end
