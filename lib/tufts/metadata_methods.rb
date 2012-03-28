#http://localhost:3000/catalog?f[subject_facet][]=Wriston%2C+Walter+B.

module Tufts
  module MetadataMethods

    def get_subject_terms

    end

    def get_collection_link_for_object()
      get_ead_title(@document_fedora)
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