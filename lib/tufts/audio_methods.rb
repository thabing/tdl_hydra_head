module Tufts
  module AudioMethods

    def self.show_audio_player(pid)
      result = "<div id=\"playerDiv\"><div id=\"controls\"></div><ul id=\"playlist\"><li>"

      #   the following line is what we would ultimately want but it doesn't work yet
      #   result += "<a href=\"" + file_asset_path(pid) + "\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

      #   the following line works in Safari and Firefox but not in Chrome or Opera
      #   result += "<a href=\"" + datastream_disseminator_url(params[:id], "ACCESS_MP3") + "\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

      #   the following line works in Safari, Chrome and Firefox but not in Opera
      #   result += "<a href=\"http://127.0.0.1:8983/fedora/get/" + pid + "/ACCESS_MP3\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

      #   the correct way, from Mike: 
      result += "<a href=\"/file_assets/" + pid +"\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

      #   the following test works in Safari, Chrome, Firefox and Opera, proving that Opera is capable of using the yahoo media player, as in current DL prod...
      #   result += "<a href=\"http://dl.tufts.edu/ProxyServlet/?url=http://repository01.lib.tufts.edu:8080/fedora/get/tufts:AC00001/bdef:TuftsAudio/getAudioFile&filename=tufts:AC00001.mp3\" type=\"audio/mpeg\">click to play MP3 (or right-click and choose \"save as\" to download MP3)</a>"

      result += "</li></ul></div>"

      return result
    end


    def self.show_participants(fedora_obj, datastream="ARCHIVAL_XML")
      result = "<div class=\"participant_table\">\n"

      participant_number = 0
      node_sets = fedora_obj.datastreams[datastream].find_by_terms_and_value(:participants)

      node_sets.each do |node|
        node.children.each do |child|
          unless child.attributes.empty?
            participant_number += 1
            id = child.attributes["id"]
            role = child.attributes["role"]
            sex = child.attributes["sex"]
            result << "        <div class=\"participant_row\" id=\"participant" + participant_number.to_s + "\">\n"
            result << "          <div class=\"participant_id\">" + (id.nil? ? "" : id) + "</div>\n"
            result << "          <div class=\"participant_name\">" + child.text + "</div>\n"
            result << "          <div class=\"participant_role\">" + (role.nil? ? "" : role) + "</div>\n"
            result << "          <div class=\"participant_sex\">" + (sex.nil? ? "" : sex) + "</div>\n"
            result << "        </div> <!-- participant_row -->\n"
          end
        end
      end

      result << "      </div> <!-- participant_table -->\n"

      return result
    end


    def self.show_transcript(fedora_obj, active_timestamps, datastream="ARCHIVAL_XML")
      timepoints = Hash.new
      node_sets = fedora_obj.datastreams[datastream].find_by_terms_and_value(:when)

      node_sets.each do |node|
        timepoint_id = node.attributes["id"]
        timepoint_interval = node.attributes["interval"]
        unless timepoint_id.nil? || timepoint_interval.nil?
          timepoint_id = timepoint_id.value
          timepoint_interval = timepoint_interval.value
          timepoints[timepoint_id] = timepoint_interval
        end
      end

      result = "<div class=\"transcript_table\">\n"

      node_sets = fedora_obj.datastreams[datastream].find_by_terms_and_value(:u)

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
          result << "                    <div class=\"transcript_speaker\">\n"

          if (active_timestamps)
            result << "                      <a class=\"transcript_chunk_link\" href=\"javascript:YAHOO.MediaPlayer.play(thisMediaObj.track," + string_milliseconds + ");\">" + string_minutes + ":" + string_just_seconds + "</a>\n"
          else
            result << "                      <span class=\"transcript_chunk_link\">" + string_minutes + ":" + string_just_seconds + "</span>\n"
          end

          result << "                    </div> <!-- transcript_speaker -->\n"
          result << "                    <div class=\"transcript_utterance\"></div>\n"
          result << "                  </div> <!-- transcript_row -->\n"
        end
        node.children.each do |child|
          childName = child.name
          if (childName == "u")
            who = child.attributes["who"]
            result << "                  <div class=\"transcript_row\">\n"
            result << "                    <div class=\"transcript_speaker\">"+ (who.nil? ? "" : who.value) + "</div>\n"
            result << "                    <div class=\"transcript_utterance\">"+ parse_notations(child) + "</div>\n"
            result << "                  </div> <!-- transcript_row -->\n"
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

      return result
    end


    private # all methods that follow will be made private: not accessible for outside objects


    def self.parse_notations(node)
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

      return result
    end
  end
end
