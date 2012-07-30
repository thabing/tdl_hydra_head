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


  end
end
