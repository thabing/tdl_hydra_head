module Tufts
  module EADMethods


    def self.title(fedora_obj, datastream = "Archival.xml")
      result = ""
      unittitle = fedora_obj.datastreams[datastream].get_values(:unittitle).first
      unitdate = fedora_obj.datastreams[datastream].get_values(:unitdate).first

      if !unittitle.nil?
        result << unittitle + (unitdate == nil ? "" : ", " + unitdate)
      end

      return result
    end


    def self.physdesc(fedora_obj, datastream = "Archival.xml")
      result = ""
      physdescs = fedora_obj.datastreams[datastream].get_values(:physdesc).first

      if !physdescs.nil?
        result << physdescs.lstrip.rstrip
      end

      return result
    end


    def self.physdesc_split(fedora_obj, datastream = "Archival.xml")
      result = ""
      physdescs = fedora_obj.datastreams[datastream].get_values(:physdesc).first

      if !physdescs.nil?
        physdescs.split(";").each do |physdesc|
          result << (result.empty? ? "" : "<br>") + physdesc.lstrip.rstrip
        end
      end

      return result
    end


    def self.abstract(fedora_obj, datastream = "Archival.xml")
      result = ""
      abstract = fedora_obj.datastreams[datastream].get_values(:abstract).first

      if !abstract.nil?
        result << abstract
      end

      return result
    end


    def self.unitid(fedora_obj, datastream = "Archival.xml")
      result = ""
      unitid = fedora_obj.datastreams[datastream].get_values(:unitid).first

      if !unitid.nil?
        result << unitid
      end

      return result
    end


    def self.finding_aid_url(fedora_obj)
      return "/catalog/ead/" + fedora_obj.id
    end


    def self.read_more_about(fedora_obj, datastream = "Archival.xml")
      result = ""
      persname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:persname)
      corpname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:corpname)
      famname = fedora_obj.datastreams[datastream].find_by_terms_and_value(:famname)
      name = nil
      rcr_url = nil

      if !persname.empty?
        name, rcr_url = parse_origination(persname)
      elsif !corpname.empty?
        name, rcr_url = parse_origination(corpname)
      elsif !famname.empty?
        name, rcr_url = parse_origination(famname)
      end

      if !name.nil?
        result << "<a href=\"" + (rcr_url == nil ? "" : "/catalog/tufts:" + rcr_url) + "\">" + name + "</a>"
      end

      return result
    end


    def self.get_contents(fedora_obj, datastream = "Archival.xml")
      result = []
      scopecontentps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:scopecontentp)

      scopecontentps.each do |scopecontentp|
        result << scopecontentp.text
      end

      return result
    end


    def self.get_serieses(fedora_obj, datastream = "Archival.xml")  # I got a D in speling once
      return fedora_obj.datastreams[datastream].find_by_terms_and_value(:series)
    end


    def self.get_series_elements(series)
      series_id = series.attribute("id").text
      did = nil
      scopecontent = nil
      c02s = []

      # find the pertinent child elements: did, scopecontent and c02
      series.element_children.each do |element_child|
        if element_child.name == "did"
          did = element_child
        elsif element_child.name == "scopecontent"
          scopecontent = element_child
        elsif element_child.name == "c02"
          level = element_child.attribute("level")
          if !level.nil? && level.text == "subseries"
            c02s << element_child
          end
        end
      end

      return series_id, did, scopecontent, c02s
    end


    def self.get_series_title(did, ead_id, series_id, series_level, no_subseries)
      result = ""

      # process the did element
      if did != nil
        unittitle = nil
        unitdate = nil

        did.element_children.each do |did_child|
          if did_child.name == "unittitle"
            unittitle = did_child.text
          elsif did_child.name == "unitdate"
            unitdate = did_child.text
          end
        end

        # This should be a link if there are no subseries elements (ie, <c02 level="subseries"> tags).
        if unittitle != nil && unittitle.size > 0
          if !unittitle.nil?
            result << ((no_subseries ? "<a href=\"/catalog/ead/" + ead_id + "/" + series_id + "\">" : "") + series_level + ". " + unittitle + (unitdate == nil ? "" : ", " + unitdate) + (no_subseries ? "</a>" : ""))
          end
        end
      end

      return result
    end


    def self.get_series_paragraphs(scopecontent)
      result = []

      # process the scopecontent element
      if scopecontent != nil
        scopecontent.element_children.each do |scopecontent_child|
          if scopecontent_child.name == "p"
            result << scopecontent_child.text
          end
        end
      end

      return result
    end


    def self.get_names_and_subjects(fedora_obj, datastream = "Archival.xml")
      result = []
      controlaccesses = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controlaccess)

      controlaccesses.each do |controlaccess|
        controlaccess.element_children.each do |element_child|
          childname = element_child.name

          if (childname == "persname" || childname == "corpname" || childname == "subject" || childname == "geogname")
            child_name = element_child.text
            child_id = element_child.attribute("id")
            child_url = (child_id == nil ? nil : child_id.text)

            if child_name.size > 0
              result << ((child_url == nil ? "" : "<a href=\"/catalog/" + child_url + "\">") + child_name + (child_url == nil ? "" : "</a>"))
            end
          end
        end
      end

      return result
    end


    def self.get_related_material(fedora_obj, datastream = "Archival.xml")
      result = []
      separatedmaterials = fedora_obj.datastreams[datastream].find_by_terms_and_value(:separatedmaterial)
      relatedmaterials = fedora_obj.datastreams[datastream].find_by_terms_and_value(:relatedmaterial)

      separatedmaterials.each do |separatedmaterial|
        result << separatedmaterial.text
      end

      relatedmaterials.each do |relatedmaterial|
        result << relatedmaterial.text
      end

      return result
    end


    def self.get_access_and_use(fedora_obj, datastream = "Archival.xml")
      result = []
      accessrestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:accessrestrictp)
      userestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:userestrictp)
      preferciteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:prefercitep)

      accessrestrictps.each do |accessrestrictp|
        result << accessrestrictp.text
      end

      userestrictps.each do |userestrictp|
        result << userestrictp.text
      end

      # TBD -- do they want the prefercite?  It's not on the design drawings...
      preferciteps.each do |prefercitep|
        result << "Preferred citation: " + prefercitep.text
      end

      return result
    end


    def self.get_processing_notes(fedora_obj, datastream = "Archival.xml")
      result = []
      processinfos = fedora_obj.datastreams[datastream].find_by_terms_and_value(:processinfo)

      processinfos.each do |processinfo|
        result << processinfo.text
      end

      return result
    end


    def self.get_acquisition_info(fedora_obj, datastream = "Archival.xml")
      result = []
      acqinfos = fedora_obj.datastreams[datastream].find_by_terms_and_value(:acqinfo)

      acqinfos.each do |acqinfo|
        result << acqinfo.text
      end

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
          rcr_url = first_element_id.text
        end
      end

      return name, rcr_url
    end


# old stuff before Ilene's styles were implemented
=begin


    def self.show_landing_page(fedora_obj, datastream = "Archival.xml")
      result = ""
      unittitle = fedora_obj.datastreams[datastream].get_values(:unittitle).first
      unitdate = fedora_obj.datastreams[datastream].get_values(:unitdate).first
      physdesc = fedora_obj.datastreams[datastream].get_values(:physdesc).first
      abstract = fedora_obj.datastreams[datastream].get_values(:abstract).first

      result << "<div id=\"ead_landing\">\n"
      result << (unittitle == nil ? "" : "            <h4>" + unittitle + (unitdate == nil ? "" : " " + unitdate) + "</h4>\n")
      result << "            <hr/>\n"
      result << "            <a href=\"/catalog/ead/" + fedora_obj.id + "\">View Collection Guide</a>\n"
      result << "            <div>A short explanation of a collection guide</div>\n"
      result << "            <a href=\"foo\">View Online Materials</a>\n"
      result << "            <div>View digitized objects from this collection.  Not all materials in this collection are available online.  See collection guide or contact DCA for more information.</div>\n"
      result << "            <div>This collection has:</div>\n"
      result << (physdesc == nil ? "" : "            <div>" + physdesc + "</div>\n")
      result << (abstract == nil ? "": "            <div>" + abstract + "</div>\n")
      result << "          </div> <!-- ead_landing -->"

      return result
    end


    def self.show_overview_page(fedora_obj, datastream = "Archival.xml")
      result = ""
      table_of_contents = ""
      overview = show_overview(fedora_obj)
      contents = show_contents(fedora_obj)
      series_descriptions = show_series_descriptions(fedora_obj)
      names_and_subjects = show_names_and_subjects(fedora_obj)
      related_collections = show_related_collections(fedora_obj)
      access_and_use = show_access_and_use(fedora_obj)
      administrative_notes = show_administrative_notes(fedora_obj)

      table_of_contents << "            <div id=\"tableOfContents\" class=\"ead_table_of_contents\">\n"
      table_of_contents << (overview == "" ? "" : "              <div><a href = \"#ead_overview\">Overview</div></a>\n")
      table_of_contents << (contents == "" ? "" : "              <div><a href = \"#ead_contents\">Contents</div></a>\n")
      table_of_contents << (series_descriptions == "" ? "" : "              <div><a href = \"#ead_series_descriptions\">Series Descriptions</a></div>\n")
      table_of_contents << (names_and_subjects == "" ? "" : "              <div><a href = \"#ead_names_and_subjects\">Names and Subjects</a></div>\n")
      table_of_contents << (related_collections == "" ? "" : "              <div><a href = \"#ead_related_collections\">Related Collections</a></div>\n")
      table_of_contents << (access_and_use == "" ? "" : "              <div><a href = \"#ead_access_and_use\">Access and Use</a></div>\n")
      table_of_contents << (administrative_notes == "" ? "" : "              <div><a href = \"#ead_administrative_notes\">Administrative Notes</a></div>\n")
      table_of_contents << "            </div> <!-- tableOfContents -->\n"

      overview.sub!("TOCGOESHERE", table_of_contents)

      result << overview + contents + series_descriptions +
        names_and_subjects + related_collections + access_and_use + administrative_notes
      result.chomp!  #remove the trailing \n

      return result
    end


    def self.show_overview(fedora_obj, datastream = "Archival.xml")
      result = ""
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
        name, rcr_url = parse_origination(persname)
      elsif !corpname.empty?
        name, rcr_url = parse_origination(corpname)
      elsif !famname.empty?
        name, rcr_url = parse_origination(famname)
      end

      # TBD - add collapsible list of associated RCRs if present

      result << "<div id=\"ead_overview\">\n"
      result << (unittitle == nil ? "" : "            <h4>" + unittitle + (unitdate == nil ? "" : " " + unitdate) + "</h4>\n")
      result << "            <hr/>\n"
      result << "TOCGOESHERE"
      result << (physdesc == nil ? "" : "            <div>" + physdesc + "</div>\n")
      result << (unitid == nil ? "" : "            <div>Call number: " + unitid + "</div>\n")
      result << (abstract == nil ? "": "            <div>" + abstract + "</div>\n")
      result << (name == nil ? "" : "            <div><a href=\"" + (rcr_url == nil ? "" : "/catalog/tufts:" + rcr_url) + "\">Read more about " + name + "</a></div>\n")
      result << "          </div> <!-- ead_overview -->\n"

      return result
    end


    def self.show_contents(fedora_obj, datastream = "Archival.xml")
      result = ""
      scopecontentps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:scopecontentp)

      if !scopecontentps.empty?
        result << "          <div id=\"ead_contents\">\n"
        result << "            <h4>Contents of the Collection</h4>\n"

        scopecontentps.each do |scopecontentp|
          result << "            <div>" + scopecontentp.text + "</div>\n"
        end

        result << "          </div> <!-- ead_contents -->\n"
      end

      return result
    end


    def self.show_series_descriptions(fedora_obj, datastream = "Archival.xml")
      result = ""
      serieses = fedora_obj.datastreams[datastream].find_by_terms_and_value(:series)  # I got a D in speling once

      if !serieses.empty?
        result << "          <div id=\"ead_series_descriptions\">\n"
        result << "            <h4>Series Descriptions</h4>\n"

        level = 0

        serieses.each do |item|
          level += 1
          result << show_series_description_item(item, level, fedora_obj.id)
        end

        result << "          </div> <!-- ead_series_descriptions -->\n"
      end

      return result
    end


    def self.show_series_description_item(item, level, ead_id)
      # item is a c01 element, or a c02 element if this is a recursive call
      # level is the number of this item (ie 1, 2.1, etc)

      result = ""
      did = nil
      scopecontent = nil
      c02s = Array.new

      # find the pertinent child elements: did, scopecontent and c02
      item.element_children.each do |element_child|
        if element_child.name == "did"
          did = element_child
        elsif element_child.name == "scopecontent"
          scopecontent = element_child
        elsif element_child.name == "c02"
          if element_child.attribute("level").text == "subseries"
            c02s << element_child
          end
        end
      end

      # process the did element
      if did != nil
        unittitle = nil
        unitdate = nil
        noSubseries = c02s.empty?

        did.element_children.each do |did_child|
          if did_child.name == "unittitle"
            unittitle = did_child.text
          elsif did_child.name == "unitdate"
            unitdate = did_child.text
          end
        end

        # This should be a link if there are no subseries elements (ie, <c02 level="subseries"> tags).
        if unittitle != nil && unittitle.size > 0
          item_id = item.attribute("id").text
          result << (unittitle == nil ? "" : "              <h4>" + (noSubseries ? "<a href=\"/catalog/ead/" + ead_id.to_s + "/" + item_id + "\">" : "") + level.to_s + ". " + unittitle + (unitdate == nil ? "" : " " + unitdate) + (noSubseries ? "</a>" : "") + "</h4>\n")
        end
      end

      # process the scopecontent element
      if scopecontent != nil
        scopecontent.element_children.each do |scopecontent_child|
          if scopecontent_child.name == "p"
            p = scopecontent_child.text
            result << "            <div>" + p + "</div>\n"
          end
        end
      end

      # process the subseries elements (ie, <c02 level="subseries"> tags), if any, by calling this method recursively
      c02s.each do |c02|
        level += 0.1
        result << show_series_description_item(c02, level, ead_id)
      end

      return result
    end


    def self.show_names_and_subjects(fedora_obj, datastream = "Archival.xml")
      result = ""
      controlaccesses = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controlaccess)

      if !controlaccesses.empty?
        parsed_controlaccess = parse_controlaccess(controlaccesses)

        if parsed_controlaccess != ""
          result << "          <div id=\"ead_names_and_subjects\">\n"
          result << "            <h4>Names and Subjects</h4>\n"
          result << parsed_controlaccess
          result << "          </div> <!-- ead_names_and_subjects -->\n"
        end
      end

      return result
    end


    def self.show_related_collections(fedora_obj, datastream = "Archival.xml")
      result = ""
      separatedmaterials = fedora_obj.datastreams[datastream].find_by_terms_and_value(:separatedmaterial)
      relatedmaterials = fedora_obj.datastreams[datastream].find_by_terms_and_value(:relatedmaterial)

      if !separatedmaterials.empty? || !relatedmaterials.empty?
        result << "          <div id=\"ead_related_collections\">\n"
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


    def self.show_access_and_use(fedora_obj, datastream = "Archival.xml")
      result = ""
      accessrestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:accessrestrictp)
      userestrictps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:userestrictp)
      preferciteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:prefercitep)

      if !accessrestrictps.empty? || !userestrictps.empty? || !preferciteps.empty?
        result << "          <div id=\"ead_access_and_use\">\n"
        result << "            <h4>Access and Use</h4>\n"

        accessrestrictps.each do |accessrestrictp|
          result << "            <div>" + accessrestrictp.text + "</div>\n"
        end

        userestrictps.each do |userestrictp|
          result << "            <div>" + userestrictp.text + "</div>\n"
        end

        # TBD -- do they want the prefercite?  It's not on the design drawings...
        preferciteps.each do |prefercitep|
          result << "            <div>Preferred citation: " + prefercitep.text + "</div>\n"
        end

        result << "          </div> <!-- ead_access_and_use -->\n"
      end

      return result
    end


    def self.show_administrative_notes(fedora_obj, datastream = "Archival.xml")
      result = ""
      processinfos = fedora_obj.datastreams[datastream].find_by_terms_and_value(:processinfo)
      acqinfos = fedora_obj.datastreams[datastream].find_by_terms_and_value(:acqinfo)

      if !processinfos.empty? || !acqinfos.empty?
        result << "          <div id=\"ead_administrative_notes\">\n"
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


    def self.parse_controlaccess(controlaccesses)
      result = ""

      controlaccesses.each do |controlaccess|
        controlaccess.element_children.each do |element_child|
          childname = element_child.name

          if (childname == "persname" || childname == "corpname" || childname == "subject" || childname == "geogname")
            child_name = element_child.text
            child_id = element_child.attribute("id")
            child_url = (child_id == nil ? nil : child_id.text)

            if child_name.size > 0
              result << "            <div>" +  (child_url == nil ? "" : "<a href=\"/catalog/" + child_url + "\">") + child_name + (child_url == nil ? "" : "</a>") + "</div>\n"
            end
          end
        end
      end

      return result
    end
=end


    def self.show_internal_page(fedora_obj, item_id, datastream = "Archival.xml")
      result = ""
      table_of_contents = ""
      series_overview, series = show_series_overview(fedora_obj, item_id, datastream)
      series_content_list = show_series_content_list(series)
      series_access_and_use = show_series_access_and_use(series)

      table_of_contents << "            <div id=\"tableOfContents\" class=\"ead_table_of_contents\">\n"
      table_of_contents << (series_overview == "" ? "" : "              <div><a href = \"#series_overview\">Series Overview</div></a>\n")
      table_of_contents << (series_content_list == "" ? "" : "              <div><a href = \"#series_content_list\">Detailed Contents List</div></a>\n")
      table_of_contents << (series_access_and_use == "" ? "" : "              <div><a href = \"#series_access_and_use\">Access and Use</div></a>\n")
      table_of_contents << "            </div> <!-- tableOfContents -->\n"

      series_overview.sub!("TOCGOESHERE", table_of_contents)

      result << series_overview + series_content_list + series_access_and_use
      result.chomp!  #remove the trailing \n

      return result
    end


    def self.show_series_overview(fedora_obj, item_id, datastream = "Archival.xml")
      result = ""
      ead_id = fedora_obj.id
      ead_title = fedora_obj.datastreams[datastream].get_values(:unittitle).first
      ead_date = fedora_obj.datastreams[datastream].get_values(:unitdate).first
      serieses = fedora_obj.datastreams[datastream].find_by_terms_and_value(:series)
      series = nil
      series_level = 0
      subseries_level = 0

      # look for a c01 whose id matches item_id
      serieses.each do |item|
        series_level += 1
        subseries_level = 0
  
        if item.attribute("id").text == item_id
          series = item
        else
          # look for a c02 whose id matches item_id
          item.element_children.each do |element_child|
            if element_child.name == "c02"
              if element_child.attribute("level").text == "subseries"
                subseries_level += 1

                if element_child.attribute("id").text == item_id
                  series = element_child
                  break
                end
              end
            end
          end
        end

        if !series.nil?
          break
        end
      end

      if !series.nil?
        did = nil
        scopecontent = nil
        unittitle = nil
        unitdate = nil
        physdesc = nil

        # find the pertinent child elements: did, scopecontent
        series.element_children.each do |element_child|
          if element_child.name == "did"
            did = element_child
          elsif element_child.name == "scopecontent"
            scopecontent = element_child
          end
        end

        # process the did element
        if did != nil
          did.element_children.each do |did_child|
            if did_child.name == "unittitle"
              unittitle = did_child.text
            elsif did_child.name == "unitdate"
              unitdate = did_child.text
            elsif did_child.name == "physdesc"
              physdesc = did_child.text
            end
          end
        end

        result << "<div id=\"series_overview\">\n"
        result << "            <div><a href = \"/catalog/ead/" + ead_id + "\">< Collection Guide Overview</a></div>\n"
        result << "            <div><a href = \"foo\">Download collection guide (PDF)</a></div>\n"
        result << "            <div><a href = \"foo\">View all online materials in this collection</a></div>\n"
        result << (ead_title == nil ? "" : "            <h4>" + ead_title + (ead_date == nil ? "" : " " + ead_date) + "</h4>\n")
        result << "            <div>Not all materials in this collection are available online</div>\n"
        result << "            <hr/>\n"
        result << "TOCGOESHERE"
        result << "            <div>Series " + series_level.to_s + (subseries_level == 0 ? "" : "." + subseries_level.to_s) + "</div>\n"
        result << (unittitle == nil ? "" : "            <h4>" + unittitle + (unitdate == nil ? "" : " " + unitdate) + "</h4>\n")
        result << "            <div>This series is part of <a href = \"/catalog/" + ead_id + "\">" + ead_title + "</a></div>\n"
        result << (physdesc == nil ? "" : "            <div>" + physdesc + "</div>\n")

        # process the scopecontent element
        if !scopecontent.nil?
          scopecontent.element_children.each do |scopecontent_child|
            if scopecontent_child.name == "p"
              result << "            <div>" + scopecontent_child.text + "</div>\n"
            end
          end
        end

        result << "          </div> <!-- series_overview -->\n"
      end

      return result, series
    end


    def self.show_series_content_list(series)
      result = ""
      items = Array.new

      series.element_children.each do |series_child|
        child_name = series_child.name

        if child_name == "c02" || child_name == "c03"
          items << series_child
        end
      end

      if !items.empty?
        result << "          <div id=\"series_content_list\">\n"
        result << "            <h4>Detailed Contents List</h4>\n"
        result << "            <div><a href=\"/foo\">Expand all folders</a></div>\n"
        result << "            <div><a href=\"/foo\">Contact DCA</a> to view material that isn't online</div>\n"
        result << "            <div class=\"ead_contents_table\">\n"
        result << "              <div class=\"ead_contents_row\">\n"
        result << "                <div class=\"ead_contents_item\"><b>Title</b></div>\n"
        result << "                <div class=\"ead_contents_item\">Type</div>\n"
        result << "                <div class=\"ead_contents_item\">Location</div>\n"
        result << "                <div class=\"ead_contents_item\">Id</div>\n"
        result << "              </div> <!-- ead_contents_row -->\n"

        items.each do |item|
          result << show_series_content_item(item, false)
        end

        result << "            </div> <!-- ead_contents_table -->\n"
        result << "          </div> <!-- series_content_list -->\n"
      end

      return result
    end


    def self.show_series_content_item(item, indent)
      result = ""
      did = nil
      daogrp = nil
      next_level_items = Array.new

      item.element_children.each do |item_child|
        if item_child.name == "did"
          did = item_child
        elsif item_child.name == "daogrp"
          daogrp = item_child
        elsif item_child.name == "c03" || item_child.name == "c04"
          next_level_items << item_child
        end
      end

      if !did.nil?
        unittitle = nil
        unitdate = nil
        physdesc = nil
        physloc = nil
        item_id = item.attribute("id")
        page = nil
        thumbnail = nil

        did.element_children.each do |did_child|
          if did_child.name == "unittitle"
            unittitle = did_child.text
          elsif did_child.name == "unitdate"
            unitdate = did_child.text
          elsif did_child.name == "physdesc"
            physdesc = did_child.text
          elsif did_child.name == "physloc"
            physloc = did_child.text
          end
        end

        if !daogrp.nil?
          daogrp.element_children.each do |daogrp_child|
            if daogrp_child.name == "daoloc"
              daoloc_label = daogrp_child.attribute("label")
              daoloc_href = daogrp_child.attribute("href")

              if !daoloc_label.nil? && !daoloc_href.nil?
                daoloc_label_text = daoloc_label.text
                daoloc_href_text = daoloc_href.text

                if daoloc_label_text == "page"
                  page = daoloc_href_text
                elsif daoloc_label_text == "thumbnail"
                  thumbnail = daoloc_href_text
                end
              end
            end
          end
        end

        result << "              <div class=\"ead_contents_row\">\n"
        result << "                <div class=\"ead_contents_item\">" + (indent ? "&nbsp;&nbsp;" : "<b>") + (page == nil ? "" : "<a href=\"/catalog/" + page + "\">") + (unittitle == nil ? "" : unittitle) + (unitdate == nil ? "" : " " + unitdate) + (page == nil ? "" : "</a>") + (indent ? "" : "</b>") + "</div>\n"
        result << "                <div class=\"ead_contents_item\">" + (physdesc == nil ? "" : physdesc) + "</div>\n"
        result << "                <div class=\"ead_contents_item\">" + (physloc == nil ? "" : physloc) + "</div>\n"
        result << "                <div class=\"ead_contents_item\">" + (item_id == nil ? "" : item_id.text) + "</div>\n"
        result << "              </div> <!-- ead_contents_row -->\n"

        next_level_items.each do |next_level_item|
          result << show_series_content_item(next_level_item, true)
        end
      end

      return result
    end


    def self.show_series_access_and_use(series)
      result = ""
      access_restrict = nil
      use_restrict = nil

      series.element_children.each do |series_child|
        if series_child.name == "accessrestrict"
          access_restrict = series_child
        elsif series_child.name == "userestrict"
          use_restrict = series_child
        end
      end

      if !access_restrict.nil? || !use_restrict.nil?
        result << "          <div id=\"series_access_and_use\">\n"
        result << "            <h4>Access and Use</h4>\n"

        if !access_restrict.nil?
          access_restrict.element_children.each do |access_child|
            if access_child.name == "p"
              result << "            <div>" + access_child.text + "</div>\n"
            end
          end
        end

        if !use_restrict.nil?
          use_restrict.element_children.each do |use_child|
            if use_child.name == "p"
              result << "            <div>" + use_child.text + "</div>\n"
            end
          end
        end

        result << "          <div> <!-- series_access_and_use -->\n"
      end

      return result
    end


  end
end
