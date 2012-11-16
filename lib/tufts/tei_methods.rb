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

    #####
    # Code for getting figures
    #####
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

    ####################
    # Table of Contents
    ####################
    def self.get_toc(fedora_obj)
      chapter_list = Array.new
      toc_result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')

      unless node_sets.nil?
        node_sets.each do |node|
          title = "Title Page"
          unless node['n'].nil?
            title = node['n']
          end
          toc_result += TOC_PREDICATE + "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+(node['id'].nil? ? "title" : node['id'])+"'>" + title + "</a>" + TOC_SUFFIX
          chapter_list << (node['id'].nil? ? 'title' : node['id'])
        end
      end

      node_sets = xml.xpath('/TEI.2/text/body/div1')

      unless node_sets.nil?
        node_sets.each do |node|
          if node['type'] == 'section'
            toc_result += TOC_COLLAPSE_PREDICATE + "<a class='collapse_td' href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node['id']+"'>" + node['n'] + "</a>"
            toc_result += "<div class='collapse_content'>"
            toc_result2, chapter_list = self.get_subsection(fedora_obj, node, chapter_list)
            toc_result += toc_result2
            toc_result += "</div>"
            toc_result += TOC_SUFFIX
          else
            toc_result += TOC_PREDICATE + "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node['id']+"'>" + node['n'] + "</a>" + TOC_SUFFIX
            chapter_list << node['id']
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

          toc_result += TOC_PREDICATE + "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+(node['id'].nil? ? "title" : node['id'])+"'>" + title + "</a>" + TOC_SUFFIX
          chapter_list << node['id']
        end
      end

      return toc_result, chapter_list
    end

    def self.get_subsection(fedora_obj, node, chapter_list)
      result = ""
      id = node['id']
      node_sets = node.xpath('/TEI.2/text/body/div1[@id="'+ id +'"]/div2')
      unless node_sets.nil?
        node_sets.each do |node2|
          result << "<a href='/catalog/tei/"+ fedora_obj.pid+"/chapter/"+node2['id']+"'>" + node2['n'] + "</a><br/>"
          chapter_list << node2['id']
        end
      end
      return result, chapter_list
    end


    ####################
    # TEI Cover Page
    ####################
    def self.show_tei_cover(fedora_obj, chapter)
      result = ""
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      # tei cover will be one of these 2 elements.
      node_sets = xml.xpath('/TEI.2/text/front/div1|/TEI.2/text/front/titlePage')

      result += self.show_tei_table_start

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

      result += self.show_tei_table_end

      result
    end

    def self.show_tei_backpage(fedora_obj, chapter)
      result = ""
      result += self.show_tei_table_start
      xml = fedora_obj.datastreams["Archival.xml"].ng_xml
      node_sets = xml.xpath('/TEI.2/text/back/div1')
      unless node_sets.nil?
        node_sets.each do |node|
          if chapter == 'title' || (chapter != "title" && chapter == node['id'])
            result << self.ctext(node)
          end
        end
      end

      result += self.show_tei_table_end
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

    def self.show_tei_table_start
      return '<table cellpadding="2" cellspacing="5" class="noborder bookviewer_table"><tbody>'
    end

    def self.show_tei_table_end
      return '</tbody></table>'
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

      return show_tei_page(fedora_obj, chapter)
    end

    def self.render_pb(node)
      result = "<p>" + node['n'] + "</p>"
      result
    end

    def self.get_block_quote(node)
      result = '<blockquote>'

      children = node.children
      children.each do |child|
        child_text = child.text.to_s.strip

          result += "<p>" + child.text + "</p>"
        end
      result += "</blockquote>"
      result
    end

    def self.render_subject_terms(fedora_obj, chapter)
      result = '<tr><td>&nbsp;</td><td>'
      # at the end of the chapter/ look for subject terms list, print header.
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/list/head|//body/div1/div2[@id="' + chapter +'"]/list/head')

      unless node_sets.nil?
        node_sets.each do |node|
          result += "<h5 class=subject_terms>" + node + "</h5>"

        end
      end

      # at the end of the chapter/ look for subject terms list, print actual list with subject searches.
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/list/item|//body/div1/div2[@id="' + chapter +'"]/list/item')

      unless node_sets.nil?
        node_sets.each do |node|

          result += "<div class=subject_list_item><a href='/catalog?f[subject_facet][]="+ node+"'>" + node + "</a></div>"

        end
      end

      result += '</tr></td>'
      result
    end
    def self.get_foot_note(child)
      footnotes =""
      result = "<a href='#'>[" + child['n'] + "]</a>&nbsp;"

      child_text = child.text.to_s.strip

      if child.name == "note"
       footnotes = "<p>["+ child['n'] +"] " + child_text + "</p>"
      end

      return result, footnotes
    end

    def self.render_page_p(node, in_left_td)
      result = ''
      footnotes =""
      children = node.children
      result +="<p>"
      children.each do |child|
        child_text = child.text.to_s.strip
        if child.name == "text" && !child_text.empty? && child.type == 3
          if in_left_td
            result += switch_to_right
            result += "<td>"
            in_left_td = false
          end
          result +=  child.text
        elsif child.name == "pb"
          unless in_left_td
            result += switch_to_left
          end
          result += render_pb(child)
          in_left_td = true
        elsif child.name == "figure"
          unless in_left_td
            result += switch_to_left
            in_left_td = true
          end
          result +="<ul class=thumbnails><li>"
          #result +='<a data-toggle="modal" href="#myImageOverlay"  class="thumbnail">'
          pid = PidMethods.urn_to_pid(child['n'])
          result +='<a data-toggle="modal" data-pid="'+ pid+'" href="/catalog/' + pid + '"  class="thumbnail">'
#          <%= link_to image_tag("/file_assets/thumb/"+document[:id] , :alt=>document[:title],:class=>"thumbnailwidth"), "/catalog/" + document[:id],:class=>"thumbnail" %>


          result +='<img src="/file_assets/thumb/' + pid + '">'
          result +="</a>"
          result +="</li></ul>"
        elsif child.name == "quote"
          if in_left_td
            result += switch_to_right
            result += "<td>"
            in_left_td = false
          end
          result += get_block_quote(child)
        elsif child.name == "note"
          result_fn, result_foot = get_foot_note(child)
          result += result_fn
          footnotes += result_foot
        end

      end
      result +="</p>"


      return result, in_left_td, footnotes
    end

    def self.switch_to_right
      return "</td>"
    end

    def self.switch_to_left
      return "</td><tr><td class=pagenumber>"
    end

    def self.render_footnotes(footnotes)
      result =""
      unless footnotes.nil? || footnotes.empty?
        result = "<tr><td>&nbsp;</td><td>"
        result += "<br/>"
        result += "<span class=maintextviewer-footnotesheader>Footnotes:</span><hr/>"
        result += footnotes
        result += "</td></tr>"
      end

      result
    end

    def self.show_tei_page(fedora_obj, chapter)
      # render the requested chapter.
      # NOTE: should break this out into a method probably.
      result = ""
      footnotes =""

      # get the header for the chapter
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/head|//body/div1/div2[@id="' + chapter +'"]/head')
      unless node_sets.nil?
        node_sets.each do |node|
          result += "<h6>" + node + "</h6><br/>"

        end
      end

      result += self.show_tei_table_start


      # get the chapter text.
      node_sets = fedora_obj.datastreams["Archival.xml"].ng_xml.xpath('//body/div1[@id="' + chapter +'"]/p|//body/div1/div2[@id="' + chapter +'"]/p|//body/div1[@id="' + chapter +'"]/quote|//body/div1/div2[@id="' + chapter +'"]/quote')
      in_left_td = true

      unless node_sets.nil?
        node_sets.each do |node|

          node_text = node.text.to_s.strip
          unless node_text.nil? || node_text.empty?
            result += "<tr>"
            result += "<td class=pagenumber>"
            case node.name
              when "pb"
                result += render_pb(node)
                in_left_td = true
              when "quote"
                if in_left_td
                  result += switch_to_right
                  result += "<td>"
                  in_left_td = false
                end

                result += get_block_quote(node)
              when "p"
                #if we're in the left close it.
                if in_left_td
                  result += switch_to_right
                  in_left_td = false
                end

                result += "<td>"

                result_p, in_left_td2, footnotes2 = render_page_p(node,in_left_td)
                in_left_td = in_left_td2
                footnotes += footnotes2
                result += result_p

              else
                if in_left_td
                  result += switch_to_right
                  in_left_td = false
                end
                puts "else"
            end
            if in_left_td
              result +="</td><td>&nbsp;</td>"
              in_left_td = true
            else
              result += "</td>"
              in_left_td=true
            end
            result += "</tr>"
          end
        end
      end

      result += render_subject_terms(fedora_obj, chapter)
      result += render_footnotes(footnotes)
      result += self.show_tei_table_end
      return result
    end


    # private # all methods that follow will be made private: not accessible for outside objects


  end

end
