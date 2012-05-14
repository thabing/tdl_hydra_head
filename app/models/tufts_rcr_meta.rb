# 2011-10-14
#
# For parsing the Record Creator Record xml
#
# Since we're new to opinionated metadata rather than drive yourself nuts make sure to read
# the rdoc: http://rubydoc.info/gems/om/1.2.2/frames
#
  class TuftsRcrMeta < TuftsDatastream

    set_terminology do |t|
      t.root(:path => "eac-cpf", "xmlns" => "urn:isbn:1-931666-33-4",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:xlink" => "http://www.w3.org/1999/xlink",
        "xsi:schemaLocation" => "urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd")
      t.recordId(:path => "recordId")
      t.maintenanceStatus(:path => "maintenanceStatus")
      t.maintenanceAgency(:path => "maintenanceAgency")
      t.languageDeclaration(:path => "languageDeclaration")
      t.conventionDeclaration(:path => "conventionDeclaration")
      t.maintenanceHistory(:path => "maintenanceHistory")
      t.sources(:path => "sources")
      t.identity(:path => "identity")
      t.description(:path => "description")
      t.biogHist(:path => "biogHist")
      t.structureOrGenealogy(:path => "structureOrGenealogy")
      t.cpfRelation(:path => "cpfRelation")
      t.resourceRelation(:path => "resourceRelation")
    end


    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.tuftsRecordCreatorRecord() {
          xml.control {
            xml.recordId
            xml.maintenanceStatus
            xml.maintenanceAgency {
              xml.agencyCode
              xml.agencyName
            }
            xml.languageDeclaration {
              xml.language
              xml.script
            }
            xml.conventionDeclaration {
              xml.abbreviation
              xml.citation
              xml.descriptiveNote
            }
            xml.maintenanceHistory {
              xml.maintenanceEvent {
                xml.eventType
                xml.eventDateTime
                xml.agentType
                xml.agent
              }
            }
            xml.sources {
              xml.source {
                xml.sourceEntry
              }
            }
          }
          xml.cpfDescription {
            xml.identity {
              xml.entityType
              xml.nameEntry {
                xml.part
                xml.authorizedForm
              }
            }
            xml.description {
              xml.existDates {
                xml.dateRange {
                  xml.fromDate
                  xml.toDate
                }
              }
              xml.biogHist {
                xml.abstract
                xml.p
              }
              xml.structureOrGenealogy
            }
          }

          xml.relations {
            xml.cpfRelation {
              xml.relationEntry
              xml.dateRange {
                xml.fromDate
                xml.toDate
              }
            }
            xml.resourceRelation {
              xml.relationEntry
              xml.objectXMLWrap {
                xml.ead {
                  xml.archdesc {
                    xml.did {
                      xml.unittitle
                      xml.unitid
                    }
                  }
                }
              }
            }
          }
        }
      end

      return builder.doc
    end

  end
