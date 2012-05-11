# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
class CatalogController < ApplicationController

  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Catalog

  # These before_filters apply the hydra access controls
  before_filter :enforce_access_controls
  before_filter :enforce_viewing_context_for_show_requests, :only=>:show
  before_filter :instantiate_controller_and_action_names
  before_filter :load_fedora_document, :only=>[:show, :edit, :eadoverview, :eadinternal]

  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic << :add_access_controls_to_solr_params
  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.solr_search_params_logic << :exclude_unwanted_models


  def instantiate_controller_and_action_names
      @current_action = action_name
      @current_controller = controller_name
  end

  def enforce_facet_permissions
    return
  end

  def enforce_opensearch_permissions
    return
  end

  def enforce_range_limit_permissions

  end

  def enforce_eadoverview_permissions
  end

  def enforce_eadinternal_permissions
  end

  def search
    delete_or_assign_search_session_params

          extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => "RSS for results")
          extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => "Atom for results")

          (@response, @document_list) = get_search_results
          @filters = params[:f] || []
          search_session[:total] = @response.total unless @response.nil?

          respond_to do |format|
            format.html { save_current_search_params }
            format.rss  { render :layout => false }
            format.atom { render :layout => false }
          end
  end

  def eadoverview
  end

  def eadinternal
    @item_id = params[:item_id]
  end

end
