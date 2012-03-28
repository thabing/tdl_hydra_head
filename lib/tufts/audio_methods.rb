module Tufts
module AudioHelper
  def showTranscriptFromDatastream(datastream)
    result = "<div class=\"participant_section\">\n"
    result << "            <h1 class=\"participant_header\">Interview Participants</h1>\n"
    result << "            <div class=\"participant_table\">\n"

    participant_number = 0
    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:participants)

    node_sets.each do |node|
      node.children.each do |child|
        unless child.attributes.empty?
          participant_number += 1
          id = child.attributes["id"]
          role = child.attributes["role"]
          sex = child.attributes["sex"]
          result << "              <div class=\"participant_row\" id=\"participant" + participant_number.to_s + "\">\n"
          result << "                <div class=\"participant_id\">" + (id.nil? ? "" : id) + ":</div>\n"
          result << "                <div class=\"participant_name\">" + child.text + "</div>\n"
          result << "                <div class=\"participant_role\">" + (role.nil? ? "" : role) + "</div>\n"
          result << "                <div class=\"participant_sex\">" + (sex.nil? ? "" : sex) + "</div>\n"
          result << "              </div> <!-- participant_row -->\n"
        end
      end
    end

    result << "            </div> <!-- participant_table -->\n"
    result << "          </div> <!-- participant_section -->\n"

    timepoints = Hash.new
    node_sets = @document_fedora.datastreams[datastream].find_by_terms_and_value(:when)

    node_sets.each do |node|
      timepoint_id = node.attributes["id"]
      timepoint_interval = node.attributes["interval"]
      unless timepoint_id.nil? || timepoint_interval.nil?
        timepoint_id = timepoint_id.value
        timepoint_interval = timepoint_interval.value
        timepoints[timepoint_id] = timepoint_interval
      end
    end

    result << "          <div class=\"transcript_section\">\n"
    result << "            <h1 class=\"transcript_header\">Transcript</h1>\n"
    result << "            <div class=\"transcript_scrollarea\">\n"
    result << "              <div class=\"transcript_table\">\n"

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
      result << "                <div class=\"transcript_chunk\" id=\"chunk" + string_total_seconds + "\">\n"
      unless (string_total_seconds == "")
        result << "                  <div class=\"transcript_row\">\n"
        result << "                    <div class=\"transcript_speaker\"></div>\n"
        result << "                    <div class=\"transcript_utterance\">\n"
        result << "                      <a class=\"transcript_chunk_link\" href=\"javascript:YAHOO.MediaPlayer.play(thisMediaObj.track," + string_milliseconds + ");\">" + string_minutes + ":" + string_just_seconds + "</a>\n"
        result << "                    </div> <!-- transcript_utterance -->\n"
        result << "                  </div> <!-- transcript_row -->\n"
      end
      node.children.each do |child|
        childName = child.name
        if (childName == "u")
          unless child.attributes.empty?
            who = child.attributes["who"]
            result << "                  <div class=\"transcript_row\">\n"
            result << "                    <div class=\"transcript_speaker\">"+ (who.nil? ? "" : who.value) + "</div>\n"
            result << "                    <div class=\"transcript_utterance\">"+ parseNotations(child) + "</div>\n"
            result << "                  </div> <!-- transcript_row -->\n"
          end
        elsif (childName == "event" || childName == "gap" || childName == "vocal" || childName == "kinesic")
          unless child.attributes.empty?
            desc = child.attributes["desc"]
            unless desc.nil?
              result << "                  <div class=\"transcript_row\">\n"
              result << "                    <div class=\"transcript_speaker\">" "</div>\n"
              result << "                    <div class=\"transcript_utterance\"><span class = \"transcript_notation\">["+ desc + "]</span></div>\n"
              result << "                  </div> <!-- transcript_row -->\n"
            end
          end
        end
      end
      result << "                </div> <!-- transcript_chunk -->\n"
    end

    result << "              </div> <!-- transcript_table -->\n"
    result << "            </div> <!-- transcript_scrollarea -->\n"
    result << "          </div> <!-- transcript_section -->"

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
      elsif (childName == "event" || childName == "gap" || childName == "vocal" || childName == "kinesic")
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
end
  end