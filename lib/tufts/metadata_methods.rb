module Tufts
  module MetadataMethods

    def show_rights
          result =""
          rights_array = get_values_from_datastream(@document_fedora, "DCA-META", [:rights])

          if rights_array.empty?
            result << "<a href=\"http://www.tufts.edu\">Link to generic rights statement</a>"
          else
            result << "<a href=\"" + rights_array.first + "\">Detailed Rights</a>"
          end
          result
    end

    def get_collection_link_for_object()
      get_ead_title(@document_fedora)
    end

    def show_creator
      showMetadataItem(nil, "creator", :creator, "h5")
    end

    def show_title
      showMetadataItem(nil, "title", :title, nil)

    end

    def showMetadataItem(label, tagID, metadataKey, *args)
      return showMetadataItemForDatastream("DCA-META", label, tagID, metadataKey, args[0])
    end

    def show_pid(pid)
      result =""
      result += "<div class=\"metadata_row\" id=\"" + "pid" + "\"><div class=\"metadata_label\">" + "ID" + "</div><div class=\"metadata_values\">"
      result += pid +"</div></div>"
    end

    def showMetadataItemForDatastream(datastream, label, tagID, metadataKey, wrap_tag)
      result = ""

      unless get_values_from_datastream(@document_fedora, datastream, [metadataKey]).first.empty?

        unless label.nil?
          result += "<div class=\"metadata_row\" id=\"" + tagID + "\"><div class=\"metadata_label\">" + label + "</div><div class=\"metadata_values\">"
        end

        get_values_from_datastream(@document_fedora, datastream, [metadataKey]).each do |metadataItem|
          if wrap_tag.nil?
            result += Sanitize.clean(RedCloth.new(metadataItem, [:sanitize_html]).to_html)
          else
            result += "<" +wrap_tag + ">" + Sanitize.clean(RedCloth.new(metadataItem, [:sanitize_html]).to_html) + "</" +wrap_tag +">"
          end
        end

        unless label.nil?
          result += "</div></div>"
        end
        result
      end

      return raw(result)
    end


    def get_subject_terms
      result =""
      subject_array = get_values_from_datastream(@document_fedora, "DCA-META", [:subject])

      unless subject_array.empty?
        result << "<dd>Subject</dd>"
      end
      subject_array.each do |subject|
        result << "<dt>"+link_to(subject, "/catalog?f[subject_facet][]="+ subject)+"</dt>"
      end

      raw result
    end

    def get_genre
      result =""
      genre_array = get_values_from_datastream(@document_fedora, "DCA-META", [:genre])

      unless genre_array.empty? || genre_array.first.blank?
        result << "<dd>Genre</dd>"
      end

      genre_array.each do |genre|
        result << "<dt>"+genre+"</dt>"
      end


      raw result
    end

    def get_handle
      result ="<dd>Permanent URL</dd>"
      handle_array = get_values_from_datastream(@document_fedora, "DCA-META", [:identifier])
      result << "<dt>"+handle_array.first+"</dt>"
      raw result
    end

    def get_original_publication
      result =""
      bib_array = get_values_from_datastream(@document_fedora, "DCA-META", [:bibliographicCitation])

      unless bib_array.empty?
        result ="<dd>Original Publication</dd>"
      end

      bib_array.each do |bib|
        result << "<dt>"+bib+"</dt>"
      end


      raw result

    end

    def show_date
      result =""
      dates_array = get_values_from_datastream(@document_fedora, "DCA-META", [:dateCreated])

      if dates_array.first.blank?
        dates_array = get_values_from_datastream(@document_fedora, "DCA-META", [:temporal])
      end

      dates_array.each do |metadataItem|
        result += "<h6>" + Sanitize.clean(RedCloth.new(metadataItem, [:sanitize_html]).to_html) + "</h6>"
      end

      raw result
    end

    def get_appears_in_text()

      ebook = @document_fedora.relationships(:is_dependent_of)
      ebook_title = nil

      if ebook.first.nil?
        # there is no hasDescription
        return ""

      else
        ebook = ebook.first.gsub('info:fedora/', '')
        ebook_obj = TuftsTEI.load_instance(ebook)
        if ebook_obj.nil?
          Rails.logger.debug "EAD Nil " + ebook
        else

          ebook_title = ebook_obj.datastreams["DCA-META"].get_values(:title).first
          ebook_title = Tufts::ModelUtilityMethods.clean_ead_title(ebook_title)

        end
      end

      if ebook_title.blank?
        return ""
      else
        result = ""
        result << "<dd>This illustration appears in:</dd>"
        result << "<dt>"+link_to(ebook_title, "/catalog/"+ ebook)+"</dt>"
        raw result
      end


    end
  end
end