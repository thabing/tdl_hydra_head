# 2011-10-14
#
# For parsing the Wildlife Pathology xml
#
# Since we're new to opinionated metadata rather than drive yourself nuts make sure to read
# the rdoc: http://rubydoc.info/gems/om/1.2.2/frames
#
  class TuftsWpMeta < ActiveFedora::NokogiriDatastream

    set_terminology do |t|
      t.root(:path => "tuftsWildlifePathologyRecord",  :xmlns=>"http://demo.lib.tufts.edu/dca_file/", :schema=>"")
      t.originalFilename(:path=>"originalFilename")
      t.title(:path => "title")
      t.pictureFormat
    end

    # I thought my confusion here was in what OM was doing but its actually a lack of knowledge
    # in how Nokogiri works.
    # see here for more details:
    # http://nokogiri.org/Nokogiri/XML/Builder.html

    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.tuftsWildlifePathologyRecord(:version => "1.0", :xmlns => "http://dca.lib.tufts.edu/ontology/twp.xsd/") {
          xml.title
        }
      end

      #Feels hacky but I can't come up with another way to ensure the namespace
      #gets set correctly here.
      #builder.doc.root.name="dca_dc:dc"
      #The funny thing is that while the above makes the xml *look* like our XML
      #Fedora itself complains that the dca_dc is not bound and the XML is not well
      #formed makes me wonder if we've been generally wrong on this all along.

      return builder.doc
    end
  end