# 2012-01-25
#
# For parsing the TuftsAudioText transcript xml
#
# Since we're new to opinionated metadata rather than drive yourself nuts make sure to read
# the rdoc: http://rubydoc.info/gems/om/1.2.2/frames
#
  class TuftsAudioTextMeta < ActiveFedora::NokogiriDatastream

    set_terminology do |t|
      t.root(:path => "TEI.2", :namespace_prefix=> nil,:xmlns => "",:schema=>"http://dca.tufts.edu/schema/tei/tei2.dtd")

      t.teiHeader(:path=>"teiHeader", :namespace_prefix => nil) {

        t.fileDesc(:path=>"fileDesc", :namespace_prefix => nil) {
          t.titleStmt(:path=>"titleStmt", :namespace_prefix => nil) {
              t.title(:path => "title",:namespace_prefix => nil)
              t.author(:path => "author",:namespace_prefix => nil)
          }
        }
      }

      t.text(:path=>"text",:namespace_prefix=>nil) {
        t.body(:path=>"body",:namespace_prefix=>nil) {
          t.div1(:path=>"div1",:namespace_prefix=>nil)  {
            t.u(:path=>"u",:namespace_prefix=>nil)
            t.speaker(:path=>"u",:namespace_prefix=>nil,:attributes=>{:type=>"who"})
          }
        }
      }
      t.transcript(:proxy=>[:text,:body,:div1])
      t.title(:proxy=>[:teiHeader,:fileDesc,:titleStmt,:title])
    end


    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.tuftsAudioTranscript() {
          xml.teiHeader {
            xml.fileDesc {
              xml.titleStmt {
                xml.title
                xml.author
              }
              xml.extent
              xml.publicationStmt {
                xml.distributor {
                }
                xml.address {
                  xml.addrLine
                }
                xml.idno
                xml.availability {
                  xml.p
                }
              }
              xml.sourceDesc {
                xml.recordingStmt {
                  xml.recording {
                    xml.date
                    xml.equipment {
                      xml.p
                    }
                    xml.respStmt {
                      xml.resp
                      xml.name
                    }
                  }
                }
              }
            }
            xml.encodingDesc {
              xml.editorialDecl {
                xml.stdVals {
                  xml.p
                }
              }
              xml.classDecl {
                xml.taxonomy {
                  xml.bibl {
                    xml.title
                  }
                }
              }
            }
            xml.profileDesc {
              xml.creation {
                xml.date
              }
              xml.langUsage {
                xml.language
              }
              xml.particDesc {
                xml.person {
                  xml.p
                }
              }
            }
          }
          xml.text {
            xml.body {
              xml.timeline {
                xml.when
              }
              xml.div1 {
                xml.u {
                  xml.u
                }
              }
            }
          }
        }
      end

      return builder.doc
    end

  end
