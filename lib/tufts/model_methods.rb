require 'chronic'

# Note to self : http://stackoverflow.com/questions/3009477/what-is-rubys-double-colon-all-about

# MISCNOTES:
# There will be no facet for RCR. There will be no way to reach RCR via browse.
# 3. There will be a facet for "collection guides", namely EAD, namely the landing page view we discussed on Friday.

module Tufts
  module ModelMethods

    def to_solr(solr_doc=Hash.new,opts={})
        super
        models = self.relationships(:has_model)
        unless models.include?("info:fedora/cm:Text.RCR") || models.include?("info:fedora/afmodel:TuftsRCR")
          create_facets(self,solr_doc)
        end

        return solr_doc
    end

    def create_facets(fedora_object, solr_doc)

      index_names_info(fedora_object,solr_doc)
      index_subject_info(fedora_object,solr_doc)
      index_collection_info(solr_doc)
      index_date_info(fedora_object,solr_doc)
      index_format_info(fedora_object,solr_doc)
    end

    def index_names_info(fedora_object, solr_doc)

      [:creator,:persname,:corpname].each {|name_field|
      names = fedora_object.datastreams["DCA-META"].get_values(name_field)

      names.each {|name|

            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "names_facet", "#{name}")
        }

      } #end name_field

    end

    def index_subject_info(fedora_object,solr_doc)

      [:subject,:corpname,:persname,:geogname].each {|name_field|
      names = fedora_object.datastreams["DCA-META"].get_values(name_field)

      names.each {|name|

            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "subject_facet", "#{name}")
        }

      } #end name_field

    end
    #
    # Adds metadata about the depositor to the asset
    # Most important behavior: if the asset has a rightsMetadata datastream, this method will add +depositor_id+ to its individual edit permissions.
    #
    # Exposed visibly to users as Collection name, under the heading "Collection")
    #
    # Note: this could also be exposed via the Dublin core field "source", but the RDF is superior because it
    # contains all the possible collections, and thus would reveal, say, that Dan Dennett papers are both faculty
    # publications and part of the Dan Dennett manuscript collection.

    # Possible counter argument: because displayed facets tend to be everything before the long tail, arguably
    # collections shouldn't be displaying unless sufficient other resources in the same collections are part of the
    # result set, in which case the fine tuning enabled by using the RDF instead of the Dublin core would become
    # less relevant.

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
            last_digit= valid_date.year.to_s[3,1]
            decade_lower = valid_date.year.to_i - last_digit.to_i
            decade_upper = valid_date.year.to_i + (10-last_digit.to_i)
            if (decade_upper >= 2020)
              decade_upper ="Present"
            end
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "year_facet", "#{decade_lower} to #{decade_upper}")
            #::Solrizer::Extractor.insert_solr_field_value(solr_doc, "year_facet", "#{valid_date.year}f")
          end}
      end

    end

    # The facets in this category will have labels and several types of digital objects might fit under one label.
    #For example, if you look at the text bullet here, you will see that we have the single facet "format" which
    #includes PDF, faculty publication, and TEI).

    #The labels are:

    #Audio Includes audio, captioned audio, oral history.
    #(We might eventually consider having an Oral history dedicated facet, but that should not preclude these
    #items from being returned in audio as well)
    #Text Includes PDF, faculty publication, TEI.
    #(we might consider breaking this apart into Scholarly article, Newspaper, Journal, Manuscript,
    # Thesis/Dissertation, etc...)
    #Should it also include oral history/captioned audio, since those are heavily composed of text documents?
    #Aaron thanks no, I think yes (I think they should be in all places that are appropriate – browse writ large, not small)
    #Should it also include image with HTML fragment, since often the HTML is a textual representation of the text
    #on an image? Aaron and I think yes.
    #Eventually, when we have a good display mechanism/e-book format delivery for e-books, we should have a separate
    #sub facet for those.
    #Are athletic rosters texts? Do they get their own facet?
    #Image Includes 4 DS image, 3 DS image
    #Image with HTML fragment as well? Aaron thinks not.
    #Should this include wildlife pathology as well? Aaron thinks not – he thinks they should only deliver through
    # data sets.
    #Note that this will include the individual images used in image books and other TEI, but not the books themselves.
    #Datasets include wildlife pathology, election records, election images (if possible).
    #Thesis/Dissertation includes everything from the student work collections. I noticed that some other catalogs
    # have this as a facet.
    #Map (we have some, and I think we have metadata indicating they are maps)
    #Faculty scholarship
    #Newspaper
    #Journal/Magazine/Newspaper
    #Musical score (is this currently only Dagomba?)
    # Note that there's a lot of logic in here that the developers might tell us is impossible. For example, we are
    #talking about separating out oral histories from regular captioned audio, but that's not going to be determinable
    #by content model alone (once the Walter Wriston captioned audio goes in) which means it's a combination of content
    # model + collection. This is logic we would need to deliver to the developers, keep up to date, and they would
    #need to maintain.

    def index_format_info(fedora_object,solr_doc)
      models = fedora_object.relationships(:has_model)

        unless models.nil?
          models.each { |model|
            case model
              when "info:fedora/cm:WP","info:fedora/afmodel:TuftsWP","info:fedora/afmodel:TuftsTeiFragmented","info:fedora/cm:Text.TEI-Fragmented"
                model_s="Datasets"
              when "info:fedora/cm:Text.EAD", "info:fedora/afmodel:TuftsEAD"
                model_s = "Collection Guides"
              when "info:fedora/cm:Audio", "info:fedora/afmodel:TuftsAudio","info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText"
                model_s="Audio"
              when "info:fedora/cm:Image.4DS","info:fedora/cm:Image.3DS	","info:fedora/afmodel:TuftsImage"
                model_s="Image"
              when "info:fedora/afmodel:TuftsPdf","info:fedora/afmodel:TuftsTEI","info:fedora/cm:Text.TEI"
                model_s="Text"
              else
                model_s="Unclassified"
            end

            #First pass of model assignment done.

            #Newspaper assignment by title
            titles = fedora_object.datastreams["DCA-META"].get_values(:title)

            if titles.first.start_with?("Tufts Daily")
              model_s="Newspaper"
            end

            #Musical score assignment by subject
            subjects = fedora_object.datastreams["DCA-META"].get_values(:subject)

            if subjects.include?("Dagomba drumming")
              model_s="Musical score"
            end

            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "object_type_facet", model_s)
          }
        end
    end
  end
end
