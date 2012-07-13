require 'chronic'

# Note to self : http://stackoverflow.com/questions/3009477/what-is-rubys-double-colon-all-about

# MISCNOTES:
# There will be no facet for RCR. There will be no way to reach RCR via browse.
# 3. There will be a facet for "collection guides", namely EAD, namely the landing page view we discussed on Friday.

module Tufts
  module ModelMethods

    #  config[:sort_fields] << ['relevance', 'score desc, pub_date_sort desc, title_sort asc']
    #  config[:sort_fields] << ['year descending', 'pub_date_sort desc, title_sort asc']
    #  config[:sort_fields] << ['author ascending', 'author_sort asc, title_sort asc']
    #  config[:sort_fields] << ['title ascending', 'title_sort asc, pub_date_sort desc']
    #  config[:sort_fields] << ['year ascending', 'pub_date_sort asc, title_sort asc']
    #  config[:sort_fields] << ['author descending', 'author_sort desc, title_sort asc']
    #  config[:sort_fields] << ['title descending', 'title_sort desc, pub_date_sort desc']

    def index_sort_fields(fedora_object, solr_doc)
      #PUBDATESORT
      dates = fedora_object.datastreams["DCA-META"].get_values(:dateCreated)

      if dates.empty?
        dates = fedora_object.datastreams["DCA-META"].get_values(:temporal)
      end


      unless dates.empty?
        unparsed_date = dates[0]
        if (unparsed_date.length() == 4)
          unparsed_date += "-01-01"
        end
        valid_date = Chronic.parse(unparsed_date)
        unless valid_date.nil?
        puts "###############################"
        puts dates[0]
        puts valid_date.to_time.iso8601
        puts valid_date.iso8601(6)
        puts "###############################"
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "pub_date_sort", "#{valid_date.iso8601(6)}")
        end
      end

      #CREATOR SORT
      names = fedora_object.datastreams["DCA-META"].get_values(:creator)


      unless names.empty?
        ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "author_sort", "#{names[0]}")
      end

      #TITLE SORT

      titles = fedora_object.datastreams["DCA-META"].get_values(:title)


      unless titles.empty?
        ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "title_sort", "#{titles[0]}")
      end

    end

    def index_fulltext(solr_doc)
      full_text = ""

      # p.datastreams['Archival.xml'].content
      # doc = Nokogiri::XML(p.datastreams['Archival.xml'].content)
      # doc.xpath('//text()').text.gsub(/[^0-9A-Za-z]/, ' ')
      models = self.relationships(:has_model)

      unless models.nil?
        models.each { |model|
          case model
            when "info:fedora/cm:WP", "info:fedora/afmodel:TuftsWP", "info:fedora/afmodel:TuftsTeiFragmented", "info:fedora/cm:Text.TEI-Fragmented"
              model_s="Datasets"
            when "info:fedora/cm:Text.EAD", "info:fedora/afmodel:TuftsEAD"
              model_s = "Collection Guides"
            when "info:fedora/cm:Audio", "info:fedora/afmodel:TuftsAudio", "info:fedora/cm:Audio.OralHistory", "info:fedora/afmodel:TuftsAudioText"
              model_s="Audio"
            when "info:fedora/cm:Image.4DS", "info:fedora/cm:Image.3DS	", "info:fedora/afmodel:TuftsImage"
              model_s="Image"
            when "info:fedora/afmodel:TuftsPdf", "info:fedora/afmodel:TuftsTEI"
              model_s="Text"
            when "info:fedora/cm:Text.TEI", "info:fedora/afmodel.TuftsTEI"
              #nokogiri_doc = Nokogiri::XML(self.datastreams['Archival.xml'].content)
              nokogiri_doc = Nokogiri::XML(File.open(convert_url_to_local_path(@file_asset.datastreams["Archival.xml"].dsLocation)).read)
              full_text = nokogiri_doc.xpath('//text()').text.gsub(/[^0-9A-Za-z]/, ' ')
            else
              model_s="Unclassified"
          end }
      end

      ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "text", full_text)
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
          unless name.downcase.include? 'unknown'
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "names_facet", "#{name}")
          end
        }

      } #end name_field

    end

    def index_subject_info(fedora_object,solr_doc)

      [:subject,:corpname,:persname,:geogname].each {|name_field|
      names = fedora_object.datastreams["DCA-META"].get_values(name_field)

      names.each {|name|
          unless name.downcase.include? 'unknown'
            ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "subject_facet", "#{name}")
          end
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
      ead = self.relationships(:has_description)
      pid = self.pid.to_s
      ead_title = nil

      if ead.first.nil?
        # there is no hasDescription
        ead_title = get_collection_from_pid(ead_title,pid)
        if ead_title.nil?
          COLLECTION_ERROR_LOG.error "Could not determine Collection for : #{self.pid}"
        else
          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", ead_title)
        end
      else
        ead = ead.first.gsub('info:fedora/','')
        ead_obj = TuftsEAD.load_instance(ead)
        if ead_obj.nil?
         Rails.logger.debug "EAD Nil " + ead
        else
          ead_title = ead_obj.datastreams["DCA-META"].get_values(:title).first
          ead_title = Tufts::ModelUtilityMethods.clean_ead_title(ead_title)

          #4 additional collections, unfortunately defined by regular expression parsing. If one of these has hasDescription PID takes precedence
          #"Undergraduate scholarship": PID in tufts:UA005.*
          #"Graduate scholarship": PID in tufts:UA015.012.*
          #"Faculty scholarship": PID in tufts:PB.001.001* or tufts:ddennett*
          #"Boston Streets": PID in tufts:UA069.005.DO.* should be merged with the facet hasDescription UA069.001.DO.MS102

          ead_title = get_collection_from_pid(ead_title,pid)


        end

          ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", ead_title)
      end

         # unless collections.nil?
         #   collections.each {|collection|
         #   ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "collection_facet", "#{collection}") }
         # end
    end


    def get_ead_title(document)
      collections = document.relationships(:is_member_of_collection)
      ead = document.relationships(:has_description)
      pid = document.pid.to_s
      ead_title = nil

      if ead.first.nil?
        # there is no hasDescription
        ead_title = get_collection_from_pid(ead_title,pid)

      else
        ead = ead.first.gsub('info:fedora/', '')
        ead_obj = TuftsEAD.load_instance(ead)
        if ead_obj.nil?
          Rails.logger.debug "EAD Nil " + ead
        else
          ead_title = ead_obj.datastreams["DCA-META"].get_values(:title).first
          ead_title = Tufts::ModelUtilityMethods.clean_ead_title(ead_title)

          #4 additional collections, unfortunately defined by regular expression parsing. If one of these has hasDescription PID takes precedence
          #"Undergraduate scholarship": PID in tufts:UA005.*
          #"Graduate scholarship": PID in tufts:UA015.012.*
          #"Faculty scholarship": PID in tufts:PB.001.001* or tufts:ddennett*
          #"Boston Streets": PID in tufts:UA069.005.DO.* should be merged with the facet hasDescription UA069.001.DO.MS102

        end
      end

      if ead_title.blank?
        return ""
      else
        result=""
        result << "<dd>This object is in collection:</dd>"
        result << "<dt>"+ link_to(ead_title,"/catalog/"+ead)+"</dt>"
        raw result
      end
    end

  def get_collection_from_pid(ead_title,pid)
    if pid.starts_with? "tufts:UA005"
      ead_title = "Undergraduate scholarship"
    elsif pid.starts_with? "tufts:UA015.012"
      ead_title = "Graduate scholarship"
    elsif (pid.starts_with? "tufts:PB.001.001") || (pid.starts_with? "tufts:ddennett")
      ead_title = "Faculty scholarship"
    elsif pid.starts_with? "tufts:UA069.005.DO"
      ead_title = "Boston Streets"
    end

    ead_title
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

        if date.length() == 4
          date += "-01-01"
        end

          valid_date = Chronic.parse(date)
          unless valid_date.nil?
            last_digit= valid_date.year.to_s[3,1]
            decade_lower = valid_date.year.to_i - last_digit.to_i
            decade_upper = valid_date.year.to_i + (10-last_digit.to_i)
            if decade_upper >= 2020
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


    #Text Includes PDF, faculty publication, TEI, captioned audio.

    #Images Includes 4 DS image, 3 DS image
    #Preferably, not PDF page images, not election record images.
    #Note that this will include the individual images used in image books and other TEI, but not the books themselves.
    ##Depending on how we deal with the PDFs, this might include individual page images for PDF. Problem?

    #Datasets include wildlife pathology, election records, election images (if possible), Boston streets splash pages.
    #Periodicals any PID that begins with UP.
    #Collection guides Text.EAD
    #Audio Includes audio, captioned audio, oral history.

    def index_format_info(fedora_object,solr_doc)
      models = fedora_object.relationships(:has_model)

      model_s = nil

        unless models.nil?
          models.each { |model|
            case model
              when "info:fedora/cm:WP","info:fedora/afmodel:TuftsWP","info:fedora/afmodel:TuftsTeiFragmented","info:fedora/cm:Text.TEI-Fragmented","info:fedora/afmodel:TuftsVotingRecord","info:fedora/cm:VotingRecord"
                model_s="Datasets"
              when "info:fedora/cm:Text.EAD", "info:fedora/afmodel:TuftsEAD"
                model_s = "Collection Guides"
              when "info:fedora/cm:Audio", "info:fedora/afmodel:TuftsAudio","info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText"
                model_s="Audio"
              when "info:fedora/cm:Image.4DS","info:fedora/cm:Image.3DS","info:fedora/afmodel:TuftsImage","info:fedora/cm:Image.HTML"
                model_s="Images"
              when "info:fedora/cm:Text.PDF","info:fedora/afmodel:TuftsPdf","info:fedora/afmodel:TuftsTEI","info:fedora/cm:Text.TEI","info:fedora/cm:Text.FacPub","info:fedora/afmodel:TuftsFacultyPublication"
                model_s="Text"
              when "info:fedora/cm:Object.Generic","info:fedora/afmodel:TuftsGenericObject"
                model_s="Generic Objects"
            end

         #   if fedora_object.pid.starts_with? 'tufts:UP'
         #     model_s = "Periodicals"
         #   end

            #First pass of model assignment done.

            #Newspaper assignment by title
            #titles = fedora_object.datastreams["DCA-META"].get_values(:title)
            #
            #if titles.first.start_with?("Tufts Daily")
            #  model_s="Newspaper"
            #end

            #Musical score assignment by subject
            #subjects = fedora_object.datastreams["DCA-META"].get_values(:subject)
            #
            #if subjects.include?("Dagomba drumming")
            #  model_s="Musical score"
            #end
            if (model_s == "Text") && (fedora_object.pid.to_s.starts_with? "tufts:UP")
              model_s = "Periodicals"
            end

            if (model_s == "Images") && (fedora_object.pid.to_s.starts_with? "tufts:MS115")
              model_s="Datasets"
            end

            if model_s.nil?
              COLLECTION_ERROR_LOG.error "Could not determine Format for : #{fedora_object.pid} with model #{models.to_s}"
            else
              ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "object_type_facet", model_s)
            end


            # At this point primary classification is complete but there are some outlier cases where we want to
            # Attribute two classifications to one object, now's the time to do that
            ##,"info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText" -> needs text
            ##,"info:fedora/cm:Image.HTML" -->needs text
            if ["info:fedora/cm:Audio.OralHistory","info:fedora/afmodel:TuftsAudioText","info:fedora/cm:Image.HTML"].include? model
              ::Solrizer::Extractor.insert_solr_field_value(solr_doc, "object_type_facet", "Text")
            end


          }
        end
    end
  end
end
