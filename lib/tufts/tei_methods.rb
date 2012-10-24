module Tufts
  module TeiMethods

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
            sex = child.attributes["sex"].to_s
            result << "        <div class=\"participant_row\" id=\"participant" + participant_number.to_s + "\">\n"
            result << "          <div class=\"participant_id\">" + (id.nil? ? "" : id) + "</div>\n"
            result << "          <div class=\"participant_name\">" + child.text + "<span class=\"participant_role\">" + (role.nil? ? "" : ", " + role) + (sex.nil? ? "" : " (" + (sex == "f" ? "female" : (sex == "m" ? "male" : sex)) + ")") + "</span></div>\n"
            result << "        </div> <!-- participant_row -->\n"
          end
        end
      end

      result << "      </div> <!-- participant_table -->\n"

      return result
    end


    def self.show_tei(fedora_obj)

      result = ""

      node_sets = fedora_obj.datastreams["Archival.xml"].find_by_terms_and_value(:text)
      result = fedora_obj.datastreams["Archival.xml"].to_s
      unless node_sets.nil?
        node_sets.each do |node|
          result << node
        end
      end
      return result
    end


   # private # all methods that follow will be made private: not accessible for outside objects



  end
end
