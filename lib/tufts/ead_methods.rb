module Tufts
  module EADMethods

    def self.show_title(fedora_obj, datastream="Archival.xml")
      titleproper = fedora_obj.datastreams[datastream].get_values(:titleproper).first
      num = fedora_obj.datastreams[datastream].get_values(:num).first
      publisher = fedora_obj.datastreams[datastream].get_values(:publisher).first
      addresslines = fedora_obj.datastreams[datastream].get_values(:addressline)
      date = fedora_obj.datastreams[datastream].get_values(:date).first

      result = "<div class=\"title_section\">\n"
      result << "            <h1 align=\"center\" class=\"title_section_title\">" + titleproper + "</h1>\n"
      result << "            <h2 align=\"center\" class=\"title_section_publisher\">" + num + "</h2>\n"
      result << "            <h2 align=\"center\" class=\"title_section_publisher\">" + publisher + "</h2>\n"

      addresslines.each do |addressline|
        result << "            <h3 align=\"center\" class=\"title_section_addressline\">" + addressline + "</h3>\n"
      end

      result << "            <h3 align=\"center\" class=\"title_section_date\">" + date + "</h3>\n"
      result << "          </div> <!-- title_section -->"

      return result
    end


    def self.show_summary(fedora_obj, datastream="Archival.xml")
      didhead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:didhead)
      unittitle = fedora_obj.datastreams[datastream].find_by_terms_and_value(:unittitle)
      unitdate = fedora_obj.datastreams[datastream].find_by_terms_and_value(:unitdate)
      physdesc = fedora_obj.datastreams[datastream].find_by_terms_and_value(:physdesc)
      repository = fedora_obj.datastreams[datastream].find_by_terms_and_value(:repository)
      corpname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:corpname)

      result = "<div class=\"summary_section\">\n"
      result << "            <h4 class=\"summary_section_head\">" + didhead.first.text + "</h4>\n"
      result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">" + unittitle.attribute("label").text.chomp(":") + "</div><div class=\"metadata_values\">" + unittitle.children.first.text + "</div></div>\n"
      result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">" + unitdate.attribute("label").text.chomp(":") + "</div><div class=\"metadata_values\">" + unitdate.children.first.text + "</div></div>\n"
      result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">" + physdesc.attribute("label").text.chomp(":") + "</div><div class=\"metadata_values\">" + physdesc.children.first.text + "</div></div>\n"
      result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">" + repository.attribute("label").text.chomp(":") + "</div><div class=\"metadata_values\">" + corpname.children.first.text + "</div></div>\n"
      result << "          </div> <!-- summary_section -->"

      return result
    end


    def self.show_index_terms(fedora_obj, datastream="Archival.xml")
      controlaccesshead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controlaccesshead)
      controlaccess = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controlaccess)

      result = "<div class=\"index_terms_section\">\n"
      result << "            <h4 class=\"index_terms_section_head\">" + controlaccesshead.first.text.chomp(":") + "</h4>\n"
      result << parse_controlaccess(controlaccess)
      result << "          </div> <!-- index_terms_section -->"

      return result
    end


    def self.show_hist_biog_note(fedora_obj, datastream="Archival.xml")
      bioghisthead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:bioghisthead)
      bioghistnoteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:bioghistnotep)
      bioghistps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:bioghistp)

      result = "<div class=\"hist_biog_note_section\">\n"
      result << "            <h4 class=\"hist_biog_note_section_head\">" + bioghisthead.first.text + "</h4>\n"

      bioghistnoteps.each do |bioghistnotep|
        result << "            <p class=\"hist_biog_note_section_note_p\">" + bioghistnotep + "</p>\n"
      end

      bioghistps.each do |bioghistp|
        result << "            <p class=\"hist_biog_note_section_p\">" + bioghistp + "</p>\n"
      end

      result << "          </div> <!-- hist_biog_note_section -->"

      return result
    end


    def self.show_scope_content(fedora_obj, datastream="Archival.xml")
      scopecontenthead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:scopecontenthead)
      scopecontentnoteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:scopecontentnotep)
      scopecontentps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:scopecontentp)

      result = "<div class=\"scope_content_section\">\n"
      result << "            <h4 class=\"scope_content_section_head\">" + scopecontenthead.first.text + "</h4>\n"

      scopecontentnoteps.each do |scopecontentnotep|
        result << "            <p class=\"scope_content_section_note_p\">" + scopecontentnotep + "</p>\n"
      end

      scopecontentps.each do |scopecontentp|
        result << "            <p class=\"scope_content_section_p\">" + scopecontentp + "</p>\n"
      end

      result << "          </div> <!-- scope_content_section -->"

      return result
    end


    def self.show_access_use(fedora_obj, datastream="Archival.xml")
      accessrestricthead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:accessrestricthead)
      accessrestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:accessrestrictp)
      userestricthead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:userestricthead)
      userestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:userestrictp)
      prefercitehead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:prefercitehead)
      preferciteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:prefercitep)

      result = "<div class=\"access_use_section\">\n"
      result << "            <h4 class=\"access_use_section_access_head\">" + accessrestricthead.first.text + "</h4>\n"

      accessrestrictps.each do |accessrestrictp|
        result << "            <p class=\"access_use_section_access_p\">" + accessrestrictp + "</p>\n"
      end

      result << "            <h4 class=\"access_use_section_use_head\">" + userestricthead.first.text + "</h4>\n"

      userestrictps.each do |userestrictp|
        result << "            <p class=\"access_use_section_use_p\">" + userestrictp + "</p>\n"
      end

      result << "            <h4 class=\"access_use_section_cite_head\">" + prefercitehead.first.text + "</h4>\n"

      preferciteps.each do |prefercitep|
        result << "            <p class=\"access_use_section_cite_p\">" + prefercitep + "</p>\n"
      end

      result << "          </div> <!-- access_use_section -->"

      return result
    end


    def self.show_series_description(fedora_obj, datastream="Archival.xml")
      dscnoteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:dscnotep)
      dscps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:dscp)

      result = "<div class=\"series_description_section\">\n"
      result << "            <h4 class=\"series_description_section_label\">Series Description</h4>\n"

      dscnoteps.each do |dscnotep|
        result << "            <p class=\"series_description_section_note_p\">" + dscnotep + "</p>\n"
      end

      dscps.each do |dscp|
        result << "            <p class=\"series_description_section_p\">" + dscp + "</p>\n"
      end

      result << "          </div> <!-- series_description_section -->"

      return result
    end


    def self.show_item_list(fedora_obj, datastream="Archival.xml")
      items = fedora_obj.datastreams[datastream].find_by_terms_and_value(:items)

      result = "<div class=\"item_list_section\">\n"
      result << "            <h4 class=\"item_list_section_label\">Item List</h4>\n"
      result << "            <hr>\n"

      items.each do |item|
        # find the did and controlaccess elements
        did = nil
        controlaccess = nil

        item.element_children.each do |child|
          if child.name == "did"
            did = child
          elsif child.name == "controlaccess"
            controlaccess = child
          end
        end

        # process the did element
        if did != nil
          unittitle = nil
          physdesc = nil
          box = nil
          item = nil
          physloc = nil
          note = nil

          did.element_children.each do |didchild|
            if didchild.name == "unittitle"
              unittitle = didchild.text
            elsif didchild.name == "physdesc"
              physdesc = didchild.text
            elsif didchild.name == "container"
              if didchild.attribute("type").text == "box"
                  box = didchild.text
              elsif didchild.attribute("type").text == "item"
                  item = didchild.text
              end
            elsif didchild.name == "physloc"
              physloc = didchild.text
            elsif didchild.name == "note"
              note = didchild.text
            end
          end

          if unittitle != nil && unittitle.size > 0
            result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">Title</div><div class=\"metadata_values\">" + unittitle + "</div></div>\n"
          end

          if physdesc != nil && physdesc.size > 0
            result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">Physical Description/Format</div><div class=\"metadata_values\">" + physdesc + "</div></div>\n"
          end

          if box != nil && box.size > 0
            result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">Catalog Number</div><div class=\"metadata_values\">" + box + (item != nil && item.size > 0 ? "#" + item : "") + "</div></div>\n"
          end

          if physloc != nil && physloc.size > 0
            result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">Location</div><div class=\"metadata_values\">" + physloc + "</div></div>\n"
          end

          if note != nil && note.size > 0
            result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">Note</div><div class=\"metadata_values\">" + note + "</div></div>\n"
          end
        end

        # process the controlaccess element
        if controlaccess != nil
          result << parse_controlaccess(controlaccess)
        end

        result << "            <hr>\n"
      end

      result << "          </div> <!-- item_list_section -->"

      return result
    end


    def self.parse_controlaccess(controlaccess)
			result = ""

			controlaccess.children.each do |controlaccesschild|
				nodes = controlaccesschild.element_children
				if (nodes != nil && nodes.size > 1)
					# the nodes of the <controlaccess> tags are:
					# nodes[0] is a <head> tag containing a label
					# nodes[1] could be one of many tags like <persname>, <corpname>, <subject> or <geogname>,
					# which can be empty even though nodes[1] contains a label;
					# if that's the case, ignore the whole <controlaccess> tag
					value = nodes[1].text
					if (value != nil && value.size > 0)
						label = nodes[0].text
						result << "            <div class=\"metadata_row\"><div class=\"metadata_label\">" + label.chomp(":") + "</div><div class=\"metadata_values\">" + value + "</div></div>\n"
					end
				end
			end

			return result
		end


	end
end
