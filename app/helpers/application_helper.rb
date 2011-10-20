module ApplicationHelper

  #copied these two methods from generic_content_objects_helper.rb


  def disseminator_link(pid, datastream_name)
    return raw("<a class=\"fbImage\" href=\"#{ datastream_disseminator_url(pid, datastream_name) }\">view</a>")
  end


  def datastream_disseminator_url(pid, datastream_name)
    begin
      base_url = Fedora::Repository.instance.send(:connection).site.to_s
    rescue
      base_url = "http://localhost:8983/fedora"
    end

    return raw("#{base_url}/get/#{pid}/#{datastream_name}")
  end


  def get_google_docs_iframe(pid, datastream_name)
    return raw("<iframe src=\"http://docs.google.com/viewer?url=http://dl.dropbox.com/u/43822/tufts-UA005.036.001.00001.pdf&embedded=true\" width=\"600\" height=\"780\" style=\"border: none;\"></iframe>")
  end


  def showMetadataItem(label, tagID, metadataKey)
    result = ""

    unless get_values_from_datastream(@document_fedora, "DCA-META", [metadataKey]).first.empty?

      result += "<fieldset><legend>" + label + "</legend><div id=""" + tagID + """ class=""browse_value"">"

      get_values_from_datastream(@document_fedora, "DCA-META", [metadataKey]).each do |metadataItem|
        result += Sanitize.clean(RedCloth.new(metadataItem, [:sanitize_html]).to_html) + "<br>"
      end

      result += "</div></fieldset>"
    end

    return raw(result)
  end


  def showImage(pid)
    result = "<img src=""" + datastream_disseminator_url(pid, "Basic.jpg") + """/>"

    return raw(result)
  end

    def showPDFLink(pid)
    result = "<a href=""" + file_asset_path(pid) + """>Get PDF</a>"

    return raw(result)
  end

end
