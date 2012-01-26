# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'blacklight_range_limit/segment_calculation'
class CatalogController < ApplicationController

  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Catalog

  # These before_filters apply the hydra access controls
  before_filter :enforce_access_controls
  before_filter :enforce_viewing_context_for_show_requests, :only=>:show
  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic << :add_access_controls_to_solr_params
  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.solr_search_params_logic << :exclude_unwanted_models
  def enforce_facet_permissions
    return
  end

  def enforce_opensearch_permissions
    return
  end

  def enforce_range_limit_permissions

  end


end