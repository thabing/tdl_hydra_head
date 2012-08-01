module Tufts
  module RCRMethods


    def self.title(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:title).first
    end


    def self.dates(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:fromDate).first +
        " - " +
        fedora_obj.datastreams[datastream].get_values(:toDate).first
    end


    def self.abstract(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:bioghist_abstract).first
    end


    def self.abstract(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:bioghist_abstract).first
    end


    def self.history(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:bioghist_p)
    end


    def self.structure_or_genealogy_p(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:structure_or_genealogy_p)
    end


    def self.structure_or_genealogy_items(fedora_obj, datastream = "RCR-CONTENT")
      return fedora_obj.datastreams[datastream].get_values(:structure_or_genealogy_item)
    end


    def self.relationships(fedora_obj, datastream = "RCR-CONTENT")
      result = [];
      relationships = fedora_obj.datastreams[datastream].find_by_terms_and_value(:cpf_relations)

      relationships.each do |relationship|
        role = relationship.attribute("arcrole").text.sub("http://dca.lib.tufts.edu/ontology/rcr#", "")  # xlink:arcrole in the EAC
        name = ""
        pid = ""
        from_date = ""
        to_date = ""

        relationship.element_children.each do |child|
          childname = child.name

          if childname == "relationEntry"
            name = child.text
            pid = child.attribute("id")  # xml:id in the EAC
          elsif childname == "dateRange"
            child.element_children.each do |grandchild|
              grandchildname = grandchild.name

              if grandchildname == "fromDate"
                from_date = grandchild.text
              elsif grandchildname == "toDate"
                to_date = grandchild.text
              end
            end
          end
        end

        result << {:role => role, :name => name, :pid => pid, :from_date => from_date, :to_date => to_date}
      end

      return result;
    end


  end
end
