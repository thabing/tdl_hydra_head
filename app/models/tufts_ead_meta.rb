# 2012-04-02
#
# For parsing the EAD xml
#
# Since we're new to opinionated metadata rather than drive yourself nuts make sure to read
# the rdoc: http://rubydoc.info/gems/om/1.2.2/frames
#
  class TuftsEADMeta < ActiveFedora::NokogiriDatastream

    set_terminology do |t|
      t.root(:path => "ead", :xmlns => "http://dca.tufts.edu/schema/ead", :schema => "http://dca.lib.tufts.edu/schema/ead/ead.xsd")

      t.eadheader(:path => "eadheader") {
        t.eadid(:path => "eadid")
        t.filedesc(:path => "filedesc") {
          t.titlestmt(:path => "titlestmt") {
            t.titleproper(:path => "titleproper")
          }
          t.publicationstmt(:path => "publicationstmt") {
            t.publisher(:path => "publisher")
            t.address(:path => "address") {
              t.addressline(:path => "addressline")
            }
            t.date(:path => "date")
          }
        }
      }

      t.frontmatter(:path => "frontmatter") {
        t.titlepage(:path => "titlepage") {
          t.titleproper(:path => "titleproper")
          t.num(:path => "num")
          t.publisher(:path => "publisher")
          t.address(:path => "address") {
            t.addressline(:path => "addressline")
          }
          t.date(:path => "date")
        }
      }

      t.archdesc(:path => "archdesc") {
        t.did(:path => "did") {
          t.head(:path => "head")
          t.repository(:path => "repository") {
            t.corpname(:path => "corpname")
            t.address(:path => "address") {
              t.addressline(:path => "addressline")
            }
          }
          t.origination(:path => "origination") {
            t.persname(:path => "persname")
          }
          t.unittitle(:path => "unittitle")
          t.unitdate(:path => "unitdate")
          t.physdesc(:path => "physdesc")
        }

        t.bioghist(:path => "bioghist") {
          t.head(:path => "head")
          t.note(:path => "note") {
            t.p(:path => "p")
          }
          t.p(:path => "p")
        }

        t.scopecontent(:path => "scopecontent") {
          t.head(:path => "head")
          t.note(:path => "note") {
            t.p(:path => "p")
          }
          t.p(:path => "p")
        }

        t.descgrp(:path => "descgrp") {
          t.accessrestrict(:path => "accessrestrict") {
            t.head(:path => "head")
            t.p(:path => "p")
          }

          t.userestrict(:path => "userestrict") {
            t.head(:path => "head")
            t.p(:path => "p")
          }

          t.prefercite(:path => "prefercite") {
            t.head(:path => "head")
            t.p(:path => "p")
          }
        }

        t.controlaccess(:path => "controlaccess") {
          t.head(:path => "head")
          t.controlaccess(:path => "controlaccess")
        }
      }

#     t.eadid(:proxy => [:eadheader, :eadid])
#     t.titleproper(:proxy => [:eadheader, :filedesc, :titlestmt, :titleproper])
#     t.publisher(:proxy => [:eadheader, :filedesc, :publicationstmt, :publisher])
#     t.addressline(:proxy => [:eadheader, :filedesc, :publicationstmt, :address, :addressline])
#     t.date(:proxy => [:eadheader, :filedesc, :publicationstmt, :date])

      # Title Page
      t.titleproper(:proxy => [:frontmatter, :titlepage, :titleproper])
      t.num(:proxy => [:frontmatter, :titlepage, :num])
      t.publisher(:proxy => [:frontmatter, :titlepage, :publisher])
      t.addressline(:proxy => [:frontmatter, :titlepage, :address, :addressline])
      t.date(:proxy => [:frontmatter, :titlepage, :date])

      # Collection Summary
      t.didhead(:proxy => [:archdesc, :did, :head])
      t.repository(:proxy => [:archdesc, :did, :repository])
      t.corpname(:proxy => [:archdesc, :did, :repository, :corpname])
      t.unittitle(:proxy => [:archdesc, :did, :unittitle])
      t.unitdate(:proxy => [:archdesc, :did, :unitdate])
      t.physdesc(:proxy => [:archdesc, :did, :physdesc])

      # Index Terms
      t.controllaccesshead(:proxy => [:archdesc, :controlaccess, :head])
      t.controllaccesschildren(:proxy => [:archdesc, :controlaccess, :controlaccess])

      # Historical or Biographical Note
      t.bioghisthead(:proxy => [:archdesc, :bioghist, :head])
      t.bioghistnotep(:proxy => [:archdesc, :bioghist, :note, :p])
      t.bioghistp(:proxy => [:archdesc, :bioghist, :p])

      # Collection Scope and Content
      t.scopecontenthead(:proxy => [:archdesc, :scopecontent, :head])
      t.scopecontentnotep(:proxy => [:archdesc, :scopecontent, :note, :p])
      t.scopecontentp(:proxy => [:archdesc, :scopecontent, :p])

      # Access and Use Information
      t.accessrestricthead(:proxy => [:archdesc, :descgrp, :accessrestrict, :head])
      t.accessrestrictp(:proxy => [:archdesc, :descgrp, :accessrestrict, :p])
      t.userestricthead(:proxy => [:archdesc, :descgrp, :userestrict, :head])
      t.userestrictp(:proxy => [:archdesc, :descgrp, :userestrict, :p])
      t.prefercitehead(:proxy => [:archdesc, :descgrp, :prefercite, :head])
      t.prefercitep(:proxy => [:archdesc, :descgrp, :prefercite, :p])
    end

#    def self.xml_template
#      builder = Nokogiri::XML::Builder.new do |xml|
#        xml.tuftsEAD() {
#          xml.eadheader {
#            xml.eadid
#            xml.filedesc {
#              xml.titlestmt {
#                xml.titleproper
#              }
#              xml.publicationstmt {
#                xml.publisher
#                xml.address {
#                  xml.addressline
#                }
#                xml.date
#              }
#            }
#          }
#        }
#      end
#
#      return builder.doc
#    end

    def to_solr(solr_doc = Hash.new) # :nodoc:
      return solr_doc
    end

  end
