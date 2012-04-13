module Tufts
  module EADMethods


		def self.show_overview_page(fedora_obj, datastream = "Archival.xml")
			overview = show_overview(fedora_obj)
      contents = show_contents(fedora_obj)
      series_descriptions = show_series_descriptions(fedora_obj)
      names_and_subjects = show_names_and_subjects(fedora_obj)
      related_collections = show_related_collections(fedora_obj)
      access_and_use = show_access_and_use(fedora_obj)
      administrative_notes = show_administrative_notes(fedora_obj)

			table_of_contents = "            <div id=\"tableOfContents\">\n"
			table_of_contents << (overview == "" ? "" : "              <div><a href = \"#ead_overview\">Overview</div></a>\n")
			table_of_contents << (contents == "" ? "" : "              <div><a href = \"#ead_contents\">Contents</div></a>\n")
			table_of_contents << (series_descriptions == "" ? "" : "              <div><a href = \"#ead_series_descriptions\">Series Descriptions</a></div>\n")
			table_of_contents << (names_and_subjects == "" ? "" : "              <div><a href = \"#ead_names_and_subjects\">Names and Subjects</a></div>\n")
			table_of_contents << (related_collections == "" ? "" : "              <div><a href = \"#ead_related_collections\">Related Collections</a></div>\n")
			table_of_contents << (access_and_use == nil ? "" : "              <div><a href = \"#ead_access_and_use\">Access and Use</a></div>\n")
			table_of_contents << (administrative_notes == "" ? "" : "              <div><a href = \"#ead_administrative_notes\">Administrative Notes</a></div>\n")
			table_of_contents << "            </div> <!-- tableOfContents -->\n"

			overview.sub!("TOCGOESHERE", table_of_contents)

			result = overview + contents + series_descriptions +
			  names_and_subjects + related_collections + access_and_use + administrative_notes
			result.chomp!  #remove the trailing \n

			return result
		end


    def self.show_overview(fedora_obj, datastream = "Archival.xml"  )
      unittitle = fedora_obj.datastreams[datastream].get_values(:unittitle).first
      unitdate = fedora_obj.datastreams[datastream].get_values(:unitdate).first
      physdesc = fedora_obj.datastreams[datastream].get_values(:physdesc).first
      unitid = fedora_obj.datastreams[datastream].get_values(:unitid).first
      abstract = fedora_obj.datastreams[datastream].get_values(:abstract).first
      persname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:persname)
      corpname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:corpname)
      famname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:famname)
      name = nil
      rcr_url = nil

			if !persname.empty?
			  name, rcr_url = parse_origination(persname);
			elsif !corpname.empty?
				name, rcr_url = parse_origination(corpname);
			elsif !famname.empty?
				name, rcr_url = parse_origination(famname);
			end

			# TBD - add collapsable list of associated RCRs if present

      result = "<div id=\"ead_overview\">\n"
      result << (unittitle == nil ? "" : "            <h4>" + unittitle + (unitdate == nil ? "" : " " + unitdate) + "</h4>\n")
      result << "            <hr/>\n"
      result << "TOCGOESHERE"
      result << (physdesc == nil ? "" : "            <div>" + physdesc + "</div>\n")
      result << (unitid == nil ? "" : "            <div>Call number: " + unitid + "</div>\n")
      result << (abstract == nil ? "": "            <div>" + abstract + "</div>\n")
      result << (name == nil ? "" : "            <div><a href=\"" + (rcr_url == nil ? "" : rcr_url) + "\">Read more about " + name + "</a></div>\n")
      result << "          </div> <!-- ead_overview -->\n"

      return result
    end


    def self.show_contents(fedora_obj, datastream = "Archival.xml"  )
      result = ""
      scopecontentps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:scopecontentp)

			if !scopecontentps.empty?
      	result = "          <div id=\"ead_contents\">\n"
				result << "            <h4>Contents of the Collection</h4>\n"

      	scopecontentps.each do |scopecontentp|
					result << "            <div>" + scopecontentp.text + "</div>\n"
      	end

      	result << "          </div> <!-- ead_contents -->\n"
      end

      return result
		end


    def self.show_series_descriptions(fedora_obj, datastream = "Archival.xml"  )
      items = fedora_obj.datastreams[datastream].find_by_terms_and_value(:items)

			if !items.empty?
	      result = "          <div id=\"ead_series_descriptions\">\n"
				result << "            <h4>Series Descriptions</h4>\n"

      	items.each do |item|
        	did = nil
        	scopecontent = nil

					item.element_children.each do |child|
						if child.name == "did"
							did = child
						elsif child.name == "scopecontent"
							scopecontent = child
						end
					end

					# process the did element
					if did != nil
						unittitle = nil
						unitdate = nil

						did.element_children.each do |didchild|
							if didchild.name == "unittitle"
								unittitle = didchild.text
							elsif didchild.name == "unitdate"
								unitdate = didchild.text
							end
						end

						if unittitle != nil && unittitle.size > 0
              result << (unittitle == nil ? "" : "              <h4>" + unittitle + (unitdate == nil ? "" : " " + unitdate) + "</h4>\n")
						end
					end

					# process the scopecontent element
					if scopecontent != nil
						scopecontent.element_children.each do |scopecontentchild|
							if scopecontentchild.name == "p"
								p = scopecontentchild.text
							  result << "            <div>" + p + "</div>\n"
							end
						end
					end
				end

	      result << "          </div> <!-- ead_series_descriptions -->\n"
			end

      return result
		end


    def self.show_names_and_subjects(fedora_obj, datastream = "Archival.xml"  )
    	result = ""
      controlaccesses = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controlaccess)

			if !controlaccesses.empty?
      	result = "          <div id=\"ead_names_and_subjects\">\n"
				result << "            <h4>Names and Subjects</h4>\n"
      	result << parse_controlaccess(controlaccesses)
      	result << "          </div> <!-- ead_names_and_subjects -->\n"
      end

      return result
		end


    def self.show_related_collections(fedora_obj, datastream = "Archival.xml"  )
    	result = ""
    	separatedmaterials = []  #TBD get from xml
    	relatedmaterials = []  #TBD get from xml

			if !separatedmaterials.empty? && ! relatedmaterials.empty?
      	result = "          <div id=\"ead_related_collections\">\n"
				result << "            <h4>Related Material</h4>\n"

      	separatedmaterials.each do |separatedmaterial|
					result << "            <div>" + separatedmaterial.text + "</div>\n"
      	end

      	relatedmaterials.each do |relatedmaterial|
					result << "            <div>" + relatedmaterial.text + "</div>\n"
      	end

      	result << "          </div> <!-- ead_related_collections -->\n"
      end

      return result
		end


    def self.show_access_and_use(fedora_obj, datastream = "Archival.xml"  )
      result = ""
      accessrestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:accessrestrictp)
      userestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:userestrictp)
      preferciteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:prefercitep)

			if !accessrestrictps.empty? && !userestrictps.empty? && !preferciteps.empty?
      	result = "          <div id=\"ead_access_and_use\">\n"
				result << "            <h4>Access and Use</h4>\n"

      	accessrestrictps.each do |accessrestrictp|
        	result << "            <div>" + accessrestrictp.text + "</div>\n"
      	end

      	userestrictps.each do |userestrictp|
        	result << "            <div>" + userestrictp.text + "</div>\n"
      	end

				# TBD -- do they want the prefercite?
      	preferciteps.each do |prefercitep|
        	result << "            <div>Preferred citation: " + prefercitep.text + "</div>\n"
        end

      	result << "          </div> <!-- ead_access_and_use -->\n"
      end

      return result
		end


    def self.show_administrative_notes(fedora_obj, datastream = "Archival.xml"  )
    	result = ""
    	processinfos = []  #TBD get from xml
    	acqinfos = []  #TBD get from xml

			if !processinfos.empty? && !acqinfos.empty?
      	result = "          <div id=\"ead_administrative_notes\">\n"
				result << "            <h4>Administrative Notes</h4>\n"

      	processinfos.each do |processinfo|
        	result << "            <div>" + processinfo.text + "</div>\n"
      	end

      	acqinfos.each do |acqinfo|
        	result << "            <div>" + acqinfo.text + "</div>\n"
      	end

      	result << "          </div> <!-- ead_administrative_notes -->\n"
      end

      return result
		end

# OLD STUFF
    def self.show_series_description(fedora_obj, datastream = "Archival.xml"  )
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


    def self.show_item_list(fedora_obj, datastream = "Archival.xml"  )
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


		def self.parse_origination(node)
			name = nil
		  rcr_url = nil

			first_element = node.first

			if first_element != nil
				name = first_element.text
				first_element_id = first_element.attribute("id")

				if first_element_id != nil
					rcr_url = first_persname_id.text
				end
			end

			return name, rcr_url
		end


    def self.parse_controlaccess(controlaccesses)
			result = ""

			controlaccesses.each do |controlaccess|
			  controlaccess.element_children.each do |child|
			    childname = child.name

					if (childname == "persname" || childname == "corpname" || childname == "subject" || childname == "geogname")
					  childtext = child.text

						if childtext.size > 0
							result << "            <div>" +  childtext + "</div>\n"
						end
					end
				end
			end

			return result
		end


	end
end
