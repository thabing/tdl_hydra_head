## 
# This example config file is set up to work using the Solr request handler
# called "advanced" in the example Blacklight solrconfig.xml:
# http://github.com/projectblacklight/blacklight-jetty/blob/master/solr/conf/solrconfig.xml
#
# NOTE WELL: Using a seperate request handler is just one option, in most cases
# it's simpler to use your default solr request handler set in Blacklight itself,
# in which case you can delete/comment out this entire file!
# See README. 

#BlacklightAdvancedSearch.config.merge!(
  # :search_field => "advanced", # name of key in Blacklight URL, no reason to change usually.
  
  # Set advanced_parse_q to true to allow AND/OR/NOT in your basic/simple
  # Blacklight search, parsed by Advanced Search Plugin. 
  #:advanced_parse_q => true, 
  
 # :qt => "advanced" # name of Solr request handler, leave unset to use the same one as your Blacklight.config[:default_qt]
  
#)


  # You don't need to specify search_fields, if you leave :qt unspecified
  # above, and have search field config in Blacklight already using that
  # same qt, the plugin will simply use them. But if you'd like to use a
  # different solr qt request handler, or have another reason for wanting
  # to manually specify search fields, you can. Uses the hash format
  # specified in Blacklight::SearchFields

  BlacklightAdvancedSearch.config[:search_fields] = search_fields = []
  search_fields << {
    :key =>  'keyword',
    :solr_local_parameters => {
      :pf => "$keyword_pf",
      :qf => "$keyword_qf"
    }
  }

  search_fields << {
    :key =>  'title',
    :solr_local_parameters => {
      :pf => "$title_pf",
      :qf => "$title_qf"
    }
  }
  
  search_fields << {
    :key =>  'author',
    :display_label => 'Creator/Author',
    :solr_local_parameters => {
      :pf => "$author_pf",
      :qf => "$author_qf"
    }
  }
  
  search_fields << {
    :key =>  'collection',
    :solr_local_parameters => {
      :pf => "$collection_pf",
      :qf => "$collection_qf"
    }
  }

  search_fields << {
    :key =>  'year_start',
    :display_label => 'Year Start',
    :solr_local_parameters => {
      :pf => "$year_start_pf",
      :qf => "$year_start_qf"
    }
  }

  search_fields << {
    :key =>  'year_end',
    :display_label => 'Year End',
    :solr_local_parameters => {
      :pf => "$year_end_pf",
      :qf => "$year_end_qf"
    }
  }

  search_fields << {
    :key =>  'description',
    :solr_local_parameters => {
      :pf => "$description_pf",
      :qf => "$description_qf"
    }
  }

  search_fields << {
    :key =>  'organization',
    :display_label => 'Organizations',
    :solr_local_parameters => {
      :pf => "$organization_pf",
      :qf => "$organization_qf"
    }
  }

  search_fields << {
    :key =>  'people',
    :solr_local_parameters => {
      :pf => "$person_pf",
      :qf => "$person_qf"
    }
  }

  search_fields << {
    :key =>  'place',
    :display_label => 'Places',
    :solr_local_parameters => {
      :pf => "$place_pf",
      :qf => "$place_qf"
    }
  }

  search_fields << {
    :key =>  'topic',
    :display_label => 'Topics',
    :solr_local_parameters => {
      :pf => "$topic_pf",
      :qf => "$topic_qf"
    }
  }

  #search_fields << {
  #  :key =>  'numbers',
  #  :solr_local_parameters => {
  #    :pf => "$pf_number",
  #    :qf => "$qf_number"
  #  }
  #}

##
# The advanced search form displays facets as a limit option.
# By default it will use whatever facets, if any, are returned
# by the Solr qt request handler in use. However, you can use
# this config option to have it request other facet params than
# default in the Solr request handler, in desired.

 BlacklightAdvancedSearch.config[:form_solr_parameters] = {
   "facet.field" => [
       "object_type_facet",
       "names_facet",
       "year_facet",
       "subject_facet",
       "collection_facet"
    # "format",
    # "lc_1letter_facet",
    # "language_facet"    
   ],
   "facet.limit" => -1,  # all facet values
   "facet.sort" => "index"  # sort by index value (alphabetically, more or less)
 }
