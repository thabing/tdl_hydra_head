module Tufts
  module TeiMethods
    # this relies on all deliverable chunks being div1's or div2's
    #<xsl:variable name="front-chunks" select="(/TEI.2/text/front/div1|/TEI.2/text/front/titlePage)"/>
    #<xsl:variable name="body-chunks" select="(/TEI.2/text/body/div1[not(div2)]|/TEI.2/text/body/div1/div2)"/>
    #<xsl:variable name="back-chunks" select="(/TEI.2/text/back/div1)"/>
    TOC_PREDICATE = "<tr><td>&nbsp;</td><td>"
    TOC_COLLAPSE_PREDICATE = "<tr><td class='collapse_td'><a class='collapse' href='#'><img src='/assets/img/button_collapse.png' width='11' height='11' alt='collapse'></a></td><td>"
    TOC_SUFFIX ="</td></tr>"
    TOC_CHILD_PREDICATE = "<div class=collapsabile>"
    TOC_CHILD_SUFFIX="</div>"

    def self.get_figures(fedora_obj)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('//figure')

      unless node_sets.nil?
        node_sets.each do |node|
          #no op
        end
      end
      result
    end

    def self.get_figures_for_chapter(fedora_obj, chapter)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('//figure')

      unless node_sets.nil?
        node_sets.each do |node|
          #no op
        end
      end
      result
    end

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

      node_sets = xml.xpath('/TEI.2/text/body/div1')

      unless node_sets.nil?
        node_sets.each do |node|
          if node['type'] == 'section'
            result << TOC_COLLAPSE_PREDICATE << "<a class='collapse_td' href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node['id']+"'>" + node['n'] + "</a>"
            result << "<div class='collapse_content'>"
            result << self.get_subsection(fedora_obj, node)
            result << "</div>"
            result << TOC_SUFFIX
          else
            result << TOC_PREDICATE << "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node['id']+"'>" + node['n'] + "</a>"<< TOC_SUFFIX
          end
          #  result << ctext(node)
        end
      end

      node_sets = xml.xpath('/TEI.2/text/back/div1')

      unless node_sets.nil?
        node_sets.each do |node|
          title = "Back Page"

          unless node['n'].nil?
            title = node['n']
          end

          result << TOC_PREDICATE << "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+(node['id'].nil? ? "title" : node['id'])+"'>" + title + "</a>" << TOC_SUFFIX
        end
      end

      result
    end

    def self.get_subsection(fedora_obj, node)
      result = ""
      id = node['id']
      node_sets = node.xpath('/TEI.2/text/body/div1[@id="'+ id +'"]/div2')
      unless node_sets.nil?
        node_sets.each do |node2|
          result << "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node2['id']+"'>" + node2['n'] + "</a><br/>"
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
    def self.show_tei_cover(fedora_obj, chapter)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      # tei cover will be one of these 2 elements.
      node_sets = xml.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')

      if chapter == 'title'
        node = node_sets.first
        result << self.ctext(node)
      else
        unless node_sets.nil?
          node_sets.each do |node|
            if chapter == 'title' || (chapter != "title" && chapter == node['id'])
              result << self.ctext(node)
            end
          end
        end
      end

      result
    end

    def self.show_tei_backpage(fedora_obj, chapter)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('/TEI.2/text/back/div1')
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
      result = []
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

      # if there's no chapter specified show the cover
      if chapter.nil?
        chapter = "title"
      end

      # special case show the cover
      if chapter == "title" || (chapter.start_with? "front")
        return show_tei_cover(fedora_obj, chapter)
      end

      # special case show the back cover
      if chapter.starts_with? "back"
        return show_tei_backpage(fedora_obj, chapter)
      end

      # render the requested chapter.
      # NOTE: should break this out into a method probably.
      result = ""

      # get the header for the chapter
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/head|//body/div1/div2[@id="' + chapter +'"]/head')
      unless node_sets.nil?
        node_sets.each do |node|
          result << "<h5>" + node + "</h5>"

        end
      end

      # get the chapter text.
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/p/child::text()|//body/div1/div2[@id="' + chapter +'"]/p/child::text()')

      unless node_sets.nil?
        node_sets.each do |node|
          result << "<p>" + node + "</p>"

        end
      end

      # at the end of the chapter/ look for subject terms list, print header.
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/list/head|//body/div1/div2[@id="' + chapter +'"]/list/head')

      unless node_sets.nil?
        node_sets.each do |node|
          result << "<h5 class=subject_terms>" + node + "</h5>"

        end
      end

      # at the end of the chapter/ look for subject terms list, print actual list with subject searches.
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/list/item|//body/div1/div2[@id="' + chapter +'"]/list/item')

      unless node_sets.nil?
        node_sets.each do |node|

          result << "<a class=subject_list_item href='/catalog?f[subject_facet][]="+ node+"'>" + node + "</p>"

        end
      end


      #we've clearly scrwed up if this is true.
      if result.empty?
        result="Document empty"
      end
      return result
    end


    # private # all methods that follow will be made private: not accessible for outside objects


  end
end
