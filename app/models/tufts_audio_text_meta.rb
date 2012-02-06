# 2012-01-25
#
# For parsing the TuftsAudioText transcript xml
#
# Since we're new to opinionated metadata rather than drive yourself nuts make sure to read
# the rdoc: http://rubydoc.info/gems/om/1.2.2/frames
#
  class TuftsAudioTextMeta < ActiveFedora::NokogiriDatastream

    set_terminology do |t|
      t.root(:path => "TEI.2", "xmlns" => "http://www.tei-c.org/ns/2.0")
      t.teiHeader(:path => "teiHeader")
      t.fileDesc(:path => "fileDesc")
      t.titleStmt(:path => "titleStmt")
      t.title(:path => "title")
      t.author(:path => "author")
      t.extent(:path => "extent")
      t.publicationStmt(:path => "publicationStmt")
      t.distributor(:path => "distributor")
      t.address(:path => "address")
      t.addrLine(:path => "addrLine")
      t.idno(:path => "idno")
      t.availability(:path => "availability")
      t.sourceDesc(:path => "sourceDesc")
      t.recordingStmt(:path => "recordingStmt")
      t.recording(:path => "recording")
      t.equipment(:path => "equipment")
      t.respStmt(:path => "respStmt")
      t.resp(:path => "resp")
      t.name(:path => "name")
      t.encodingDesc(:path => "encodingDesc")
      t.editorialDecl(:path => "editorialDecl")
      t.stdVals(:path => "stdVals")
      t.classDecl(:path => "classDecl")
      t.taxonomy(:path => "taxonomy")
      t.bibl(:path => "bibl")
      t.profileDesc(:path => "profileDesc")
      t.creation(:path => "creation")
      t.date(:path => "date")
      t.langUsage(:path => "langUsage")
      t.language(:path => "language")
      t.particDesc(:path => "particDesc")
      t.person(:path => "person")
      t.p(:path => "p")
      t.text(:path => "text")
      t.body(:path => "body")
      t.timeline(:path => "timeline")
      t.when(:path => "when")
      t.div1(:path => "div1")
      t.u(:path => "u")
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
