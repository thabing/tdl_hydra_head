module Tufts
  module TeiMethods
    # this relies on all deliverable chunks being div1's or div2's
    #<xsl:variable name="front-chunks" select="(/TEI.2/text/front/div1|/TEI.2/text/front/titlePage)"/>
    #<xsl:variable name="body-chunks" select="(/TEI.2/text/body/div1[not(div2)]|/TEI.2/text/body/div1/div2)"/>
    #<xsl:variable name="back-chunks" select="(/TEI.2/text/back/div1)"/>
    TOC_PREDICATE = "<tr><td class='collapse_td'>&nbsp;</td><td>"
    TOC_SUFFIX ="</td></tr>"

    def self.get_toc(fedora_obj)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')

      unless node_sets.nil?
        node_sets.each do |node|
          title = "Title Page"
          unless node['n'].nil?
            title = node['n']
          end
          result << TOC_PREDICATE << "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+(node['id'].nil? ? "title" : node['id'])+"'>" + title + "</a>" << TOC_SUFFIX
        end
      end

      node_sets = xml.xpath('/TEI.2/text/body/div1[not(div2)]|/TEI.2/text/body/div1/div2')

      unless node_sets.nil?
        node_sets.each do |node|
          result << TOC_PREDICATE << "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node['id']+"'>" + node['n'] + "</a>"<< TOC_SUFFIX
        end
      end

      node_sets = xml.xpath('/TEI.2/text/back/div1')

      unless node_sets.nil?
        node_sets.each do |node|
          result << TOC_PREDICATE << "<a>" + "Back Page" + "</a>"<< TOC_SUFFIX
        end
      end

      result
    end

    # <front>
    #   <titlePage>
    #     <docTitle>
    #       <titlePart type="main">A Failure of Management</titlePart>
    #     </docTitle>
    #     <docAuthor> Walter B. Wriston</docAuthor>
    #     <docTitle>
    #     <titlePart type="des">Wriston, Walter B. "A Failure of Management." Sternbusiness (1995): 25-26.</titlePart>
    #       </docTitle>
    #     </titlePage>
    #  </front>
    def self.show_tei_cover(fedora_obj,chapter)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')
      unless node_sets.nil?
        node_sets.each do |node|
          if chapter == 'title' || (chapter != "title" && chapter == node['id'])
            result << self.ctext(node)
          end
        end
      end
      result
    end

    # recursive function to walk the title page stick everything into divs
    def self.ctext(el)
      if el.text?
        return el.text
      end
      result = [ ]
      for sel in el.children
        if sel.element?
          type = sel[:type]
          result.push("<div class='" + sel.name + " " + (type.nil? ? "" : type) + "'>")
        end
        result.push(ctext(sel))
        if sel.element?
          result.push("</div>")
        end
      end
      return result.join
    end

    def self.show_tei(fedora_obj, chapter)

      if chapter.nil?
        chapter = "title"
      end

      if chapter == "title" || (chapter.start_with? "front")
        return show_tei_cover(fedora_obj,chapter)
      end

      result = ""

      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/head')
      unless node_sets.nil?
        node_sets.each do |node|
          result << "<h5>" + node + "</h5>"

        end
      end


      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/p')

      unless node_sets.nil?
        node_sets.each do |node|
          result << "<p>" + node + "</p>"

        end
      end

      if result.empty?
        result="Document empty"
      end
      return result
    end


    # private # all methods that follow will be made private: not accessible for outside objects


  end
end
