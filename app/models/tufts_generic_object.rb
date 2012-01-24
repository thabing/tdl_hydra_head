require "hydra"

# 2011-10-05
#
# My take on what our record creator record content model is going to look like
# in ActiveFedora
#
# Since we're new to activefedora rather than drive yourself nuts make sure to read
# the rdoc on activefedora: http://rdoc.info/github/mediashelf/active_fedora/master/file/README.textile#
#


class TuftsGenericObject < ActiveFedora::Base

  include Hydra::ModelMethods
  include Tufts::ModelMethods

  # I haven't quite worked out how this works or if its relevant for us.
  has_relationship "parts", :is_part_of, :inbound => true

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => TuftsRightsMetadata

  # Tufts specific needed metadata streams
  has_metadata :name => "DCA-META", :type => TuftsDcaMeta

  has_metadata :name => "GENERIC-CONTENT", :type => TuftsGenericMeta


  def to_solr(solr_doc=Hash.new,opts={})
    super

    index_collection_info(solr_doc)
    index_date_info(self,solr_doc)
    ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "object_type_facet", "Generic Object")

    return solr_doc
  end

end
