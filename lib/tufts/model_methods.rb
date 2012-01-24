require 'chronic'

# Note to self : http://stackoverflow.com/questions/3009477/what-is-rubys-double-colon-all-about
module Tufts
  module ModelMethods

    #
    # Adds metadata about the depositor to the asset
    # Most important behavior: if the asset has a rightsMetadata datastream, this method will add +depositor_id+ to its individual edit permissions.
    #
    def index_collection_info(solr_doc)
      collections = self.relationships(:is_member_of_collection)
          unless collections.nil?
            collections.each {|collection|
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", "#{collection}") }
          end
    end

    #if possible, exposed as ranges, cf. the Virgo catalog facet "publication era". Under the heading
    #"Date". Also, if possible, use Temporal if "Date.Created" is unavailable.)

    #Only display these as years (ignore the MM-DD) and ideally group them into ranges. E.g.,
    ##if we had 4 items that had the years 2001, 2004, 2006, 2010, the facet would look like 2001-2010.
    #Perhaps these could be 10-year ranges, or perhaps, if it's not too difficult, the ranges could generate
    #automatically based on the available data.

    def index_date_info(fedora_object, solr_doc)
      dates = fedora_object.datastreams["DCA-META"].get_values(:dateCreated)

      if dates.empty?
        dates = fedora_object.datastreams["DCA-META"].get_values(:temporal)
      end

      if dates.empty?
        puts "THIS PID HAS NO DATE TO INDEX :::  #{fedora_object.pid}"
      else
        dates.each {|date|
          valid_date = Chronic.parse(date)
          unless valid_date.nil?
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "year_facet", "#{valid_date.year}")
          end}
      end

    end

    def index_format_info(fedora_object,solr_doc)
      models = fedora_object.relationships(:has_model)

        unless models.nil?
          models.each { |model|
            case model
              when "info:fedora/cm:WP"
                model_s="Datasets"
              when "info:fedora/cm:Audio"
                model_s="Audio"
              else
                model_s="Unclassified"
            end
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "object_type_facet", model_s)

          }
        end

    end
  end
end
