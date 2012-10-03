include Tufts::ModelMethods
include Tufts::MetadataMethods

module ApplicationHelper

  def application_name
        'Tufts Digital Library'
  end


  def showPdfImage(pid)
    result = "<img alt=\"\" src=\"/pdf_pages/" + pid + "/0\"/>"

    return raw(result)
  end

  def showImage(pid)
      result = "<img alt=\"\" src=\"" + file_asset_path(pid) + "\"/>"

      return raw(result)
    end

  def render_image_viewer_path(pid)
    imageviewer_path(pid) +"#page/1/mode/1up"
  end

  def render_image_viewer_link(pid)
    result = "<a href=\"" + render_image_viewer_path(pid) + "\"><h6>open in viewer <i class=\"icon-share\"></i></h6></a>"
    return raw(result)
  end

  def render_book_viewer_link(pid)
    result = "<a href=\"/bookreader/" + pid +"#page/1/mode/2up" + "\">full view</a>"
    result = "<a href=\"/bookreader/" + pid +"#page/1/mode/2up" + "\"><h6>open in viewer <i class=\"icon-share\"></i></h6></a>"
    return raw(result)
  end


  #http://ap.rubyonrails.org/classes/ActionController/Streaming.html#M000045
  def showGenericObjects(pid)
    blah = get_values_from_datastream(@document_fedora, "GENERIC-CONTENT", [:item])
    result = ""
    blah.each_with_index do |page, index|
      result+="<tr class=\"manifestRow\">"
      fileName = get_values_from_datastream(@document_fedora, "GENERIC-CONTENT", [:item, :fileName])[index];
      link = bucketproxy_path(pid, index);
      mimeType = get_values_from_datastream(@document_fedora, "GENERIC-CONTENT", [:item, :mimeType])[index];
      result+="<td class=\"nameCol\"><a class=\"manifestLink\" href=\"#{link}\">#{fileName}</a></td>"
      result+="<td class=\"mimeCol\">#{mimeType}</td>"
      result+="</tr>"
    end
    return raw(result)
  end
  def show_streets_link(pid)
    urn = pid.gsub("tufts:","")
#puts "#{urn}"
    del_index = urn.index(".")
#puts "#{del_index}"
    col = urn[0..(del_index-1)];
#jputs "#{col}"
    urn = "tufts:central:dca:" + col + ":" + urn 
    return "http://bcd.lib.tufts.edu/view_text.jsp?urn=" + urn
  end
  def show_elections_link(pid)
    return "http://elections.lib.tufts.edu/aas_portal/view-election.xq?id=" + pid[6..-1]
  end

  def showPDFLink(pid)
    result = "<a href=\"" + file_asset_path(pid) + "\">Get PDF</a>"

    return raw(result)
  end


  def showHTML(pid)
    result = ActiveFedora::Base.load_instance(pid).datastreams_in_memory["Content.html"].content

    return raw(result)
  end


  def render_back_to_overview_link
    link_to('Back to overview', catalog_url)

  end

  ##
  # Assumes controller has a #js_includes method, array with each
  # element being a set of arguments for javsascript_include_tag.
  # See #render_head_content for instructions on local code or plugins
  # adding js files.
  def render_js_includes
    return "" unless respond_to?(:javascript_includes)
    str = ""
    javascript_includes.collect do |args|
      if (args.to_a & %w(hydra/hydra-head jquery.form.js spin.min.js jquery-1.4.2.min.js catalog/show custom)).empty?
        str +=javascript_include_tag(*args)
      end
    end.join("\n")
    return raw("\n"+str)
  end

  ##
  # Assumes controller has a #stylesheet_link_tag method, array with
  # each element being a set of arguments for stylesheet_link_tag
  # See #render_head_content for instructions on local code or plugins
  # adding stylesheets.
  def render_stylesheet_includes
    return "" unless respond_to?(:stylesheet_links)
    str = ""
    stylesheet_links.collect do |args|
      if (args.to_a & %w(hydra/html_refactor yui)).empty?
        str+=stylesheet_link_tag(*args)
      end
    end.join("\n")
    return raw("\n"+str)
  end

  def http_referer_uri
    request.env["HTTP_REFERER"] && URI.parse(request.env["HTTP_REFERER"])
  end

  def refered_from_our_site?
    if uri = http_referer_uri
      uri.host == request.host
    end
  end

  def refered_from_a_search?
    if refered_from_our_site?
      http_referer_uri.try(:query)['search']
    end
  end
end
