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
      result << "            <h3 class=\"summary_section__head\">" + didhead.first.text + "</h3>\n"
      result << "            <p class=\"summary_section_unittitle\">" + unittitle.attribute("label") + " " + unittitle.children.first.text + "</p>\n"
      result << "            <p class=\"summary_section_unitdate\">" + unitdate.attribute("label") + " " + unitdate.children.first.text + "</p>\n"
      result << "            <p class=\"summary_section_physdesc\">" + physdesc.attribute("label") + " " + physdesc.children.first.text + "</p>\n"
      result << "            <p class=\"summary_section_repository\">" + repository.attribute("label") + " " + corpname.children.first.text + "</p>\n"
      result << "          </div> <!-- summary_section -->"

      return result
    end


    def self.show_index_terms(fedora_obj, datastream="Archival.xml")
      controllaccesshead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controllaccesshead)
      controllaccesschildren = fedora_obj.datastreams[datastream].find_by_terms_and_value(:controllaccesschildren)

      result = "<div class=\"index_terms_section\">\n"
      result << "            <h3 class=\"index_terms_section_head\">" + controllaccesshead.first.text + "</h3>\n"

      controllaccesschildren.each do |controllaccesschild|
        nodes = controllaccesschild.children;
        if (nodes != nil && nodes.size > 3)
          # the nodes of the <controllaccess> tags are:
          # nodes[0] is whitespace
          # nodes[1] is a <head> tag containing a label
          # nodes[2] is whitespace
          # nodes[3] could be one of many tags like <persname>, <corpname>, <subject> or <geogname>,
          # which can be empty even though nodes[1] contains a label;
          # if that's the case, ignore the whole <controllaccess> tag
          value = nodes[3].text;
          if (value != nil && value.size > 0)
            label = nodes[1].text;
            result << "            <p class=\"index_terms_section_child\">" + label + " " + value + "</p>\n"
          end
        end
      end

      result << "          </div> <!-- index_terms_section -->"

      return result
    end


    def self.show_hist_biog_note(fedora_obj, datastream="Archival.xml")
      bioghisthead = fedora_obj.datastreams[datastream].find_by_terms_and_value(:bioghisthead)
      bioghistnoteps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:bioghistnotep)
      bioghistps = fedora_obj.datastreams[datastream].find_by_terms_and_value(:bioghistp)

      result = "<div class=\"hist_biog_note_section\">\n"
      result << "            <h3 class=\"hist_biog_note_section_head\">" + bioghisthead.first.text + "</h3>\n"

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
      result << "            <h3 class=\"scope_content_section_head\">" + scopecontenthead.first.text + "</h3>\n"

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
      result << "            <h3 class=\"access_use_section_access_head\">" + accessrestricthead.first.text + "</h3>\n"

      accessrestrictps.each do |accessrestrictp|
          result << "            <p class=\"access_use_section_access_p\">" + accessrestrictp + "</p>\n"
      end

      result << "            <h3 class=\"access_use_section_use_head\">" + userestricthead.first.text + "</h3>\n"

      userestrictps.each do |userestrictp|
          result << "            <p class=\"access_use_section_use_p\">" + userestrictp + "</p>\n"
      end

      result << "            <h3 class=\"access_use_section_cite_head\">" + prefercitehead.first.text + "</h3>\n"

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
      result << "            <h3 class=\"series_description_section_label\">Series Description</h3>\n"

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
      result << "            <h3 class=\"item_list_section_label\">Item List</h3>\n"

      items.each do |item|
          result << "            <p class=\"series_description_section_p\">" + item.text + "</p>\n"
      end

      result << "          </div> <!-- item_list_section -->"

      return result
    end
  end
end
