module BlacklightHelper
   include Hydra::BlacklightHelperBehavior

   # currently only used by the render_document_partial helper method (below)
    def document_partial_name(document)
      return if document[Blacklight.config[:show][:display_type]].nil?
      ModelNameHelper.map_model_name(document[Blacklight.config[:show][:display_type]].first).gsub(/^[^\/]+\/[^:]+:/,"").underscore.pluralize
    end

   def render_facet_value(facet_solr_field, item, options ={})
     if item.is_a? Array
       link_to_unless(options[:suppress_link], item[0], add_facet_params_and_redirect(facet_solr_field, item[0]), :class=>"facet_select") + raw("<span class='facet_count'> (" + format_num(item[1]) + ")</span>")
     else
       text_for_link = item.value + " ("+format_num(item.hits) +")"
       link_to_unless(options[:suppress_link], text_for_link, add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select")
       #raw("<span class='facet_count'> (" + format_num(item.hits) + ")</span>"
     end
   end

end
