class LocalFileAssetsController < ApplicationController

  include Hydra::AccessControlsEnforcement
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper
  include Hydra::RepositoryController
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include TuftsFileAssetsHelper
#  before_filter :require_fedora
  before_filter :require_solr, :only => [:index, :create, :show, :destroy]
  prepend_before_filter :sanitize_update_params

  helper :hydra_uploader

  def index

    if params[:layout] == "false"
      # action = "index_embedded"
      layout = false
    end

    if params[:asset_id].nil?
      # @solr_result = ActiveFedora::SolrService.instance.conn.query('has_model_field:info\:fedora/afmodel\:FileAsset', @search_params)
      @solr_result = FileAsset.find_by_solr(:all)
    else
      container_uri = "info:fedora/#{params[:asset_id]}"
      escaped_uri = container_uri.gsub(/(:)/, '\\:')
      extra_controller_params = {:q => "is_part_of_s:#{escaped_uri}"}
      @response, @document_list = get_search_results(extra_controller_params)

      # Including this line so permissions tests can be run against the container
      @container_response, @document = get_solr_response_for_doc_id(params[:asset_id])

      # Including these lines for backwards compatibility (until we can use Rails3 callbacks)
      @container = ActiveFedora::Base.load_instance(params[:asset_id])
      @solr_result = @container.file_objects(:response_format => :solr)
    end

    # Load permissions_solr_doc based on params[:asset_id]
    #load_permissions_from_solr(params[:asset_id])

    render :action => params[:action], :layout => layout
  end

  def new
=begin
From file_assets/_new.html.haml
=render :partial=>"fluid_infusion/uploader"
=render :partial=>"fluid_infusion/uploader_js"
=end
    render :partial => "new", :layout => false
  end

  # Creates and Saves a File Asset to contain the the Uploaded file
  # If container_id is provided:
  # * the File Asset will use RELS-EXT to assert that it's a part of the specified container
  # * the method will redirect to the container object's edit view after saving
  def create
    if params.has_key?(:Filedata)
      @file_asset = create_and_save_file_asset_from_params
      apply_depositor_metadata(@file_asset)

      flash[:notice] = "The file #{params[:Filename]} has been saved in <a href=\"#{asset_url(@file_asset.pid)}\">#{@file_asset.pid}</a>."

      if !params[:asset_id].nil?
        associate_file_asset_with_container
      end

      ## Apply any posted file metadata
      unless params[:asset].nil?
        logger.debug("applying submitted file metadata: #{@sanitized_params.inspect}")
        apply_file_metadata
      end
      # If redirect_params has not been set, use {:action=>:index}
      logger.debug "Created #{@file_asset.pid}."
    else
      flash[:notice] = "You must specify a file to upload."
    end

    if !params[:asset_id].nil?
      redirect_params = {:controller => "catalog", :id => params[:asset_id], :action => :edit}
    end

    redirect_params ||= {:action => :index}

    redirect_to redirect_params
  end

  # Common destroy method for all AssetsControllers
  def destroy
    # The correct implementation, with garbage collection:
    # if params.has_key?(:container_id)
    #   container = ActiveFedora::Base.load_instance(params[:container_id])
    #   container.file_objects_remove(params[:id])
    #   FileAsset.garbage_collect(params[:id])
    # else

    # The dirty implementation (leaves relationship in container object, deletes regardless of whether the file object has other containers)
    ActiveFedora::Base.load_instance(params[:id]).delete
    render :text => "Deleted #{params[:id]} from #{params[:asset_id]}."
  end


  def showAdvanced
    @file_asset = FileAsset.find(params[:id])
    if (@file_asset.nil?)
      logger.warn("No such file asset: " + params[:id])
      flash[:notice]= "No such file asset."
      redirect_to(:action => 'index', :q => nil, :f => nil)
    else
      # get containing object for this FileAsset
      pid = @file_asset.container_id
      @downloadable = false
      # A FileAsset is downloadable iff the user has read or higher access to a parent
      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      if reader?
        @downloadable = true
      end

      mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))


      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImage"))
        if @file_asset.datastreams.include?("Advanced.jpg")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImageText"))
        if @file_asset.datastreams.include?("Advanced.jpg")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsWP"))
        if @file_asset.datastreams.include?("Advanced.jpg")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation))
        end
      end
    end
  end


  def showThumb
    @file_asset = FileAsset.find(params[:id])
    if (@file_asset.nil?)
      logger.warn("No such file asset: " + params[:id])
      flash[:notice]= "No such file asset."
      redirect_to(:action => 'index', :q => nil, :f => nil)
    else
      # get containing object for this FileAsset
      pid = @file_asset.container_id
      @downloadable = false
      # A FileAsset is downloadable iff the user has read or higher access to a parent
      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      if reader?
        @downloadable = true
      end

      mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))


      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImage"))
        if @file_asset.datastreams.include?("Thumbnail.png")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Thumbnail.png"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImageText"))
        if @file_asset.datastreams.include?("Thumbnail.png")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Thumbnail.png"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsWP"))
        if @file_asset.datastreams.include?("Thumbnail.png")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Thumbnail.png"].dsLocation))
        end
      end
    end
  end

  def dimensions
    @file_asset = FileAsset.find(params[:id])


    if (@file_asset.nil?)
      logger.warn("No such file asset: " + params[:id])
      flash[:notice]= "No such file asset."
      redirect_to(:action => 'index', :q => nil, :f => nil)
    else
      # get containing object for this FileAsset
      pid = @file_asset.container_id
      @downloadable = false
      # A FileAsset is downloadable iff the user has read or higher access to a parent
      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      if reader?
        @downloadable = true
      end

      mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))


      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImage"))
        if @file_asset.datastreams.include?("Advanced.jpg")
          imagesize = ImageSize.new File.open(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation)).read


          render :json => {:height => imagesize.get_height, :width => imagesize.get_width}
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImageText"))
        if @file_asset.datastreams.include?("Advanced.jpg")
          imagesize = ImageSize.new File.open(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation)).read
          render :json => {:height => imagesize.get_height, :width => imagesize.get_width}
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsWP"))
        if @file_asset.datastreams.include?("Basic.jpg")
          imagesize = ImageSize.new File.open(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation)).read
          render :json => {:height => imagesize.get_height, :width => imagesize.get_width}.to_s
        end
      end
    end


  end

  def show


    @file_asset = FileAsset.find(params[:id])
    if (@file_asset.nil?)
      logger.warn("No such file asset: " + params[:id])
      flash[:notice]= "No such file asset."
      redirect_to(:action => 'index', :q => nil, :f => nil)
    else
      # get containing object for this FileAsset
      pid = @file_asset.container_id
      @downloadable = false
      # A FileAsset is downloadable iff the user has read or higher access to a parent
      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      if reader?
        @downloadable = true
      end

      mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsFacultyPublication"))
        if @file_asset.datastreams.include?("Archival.pdf")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Archival.pdf"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImage"))
        if @file_asset.datastreams.include?("Basic.jpg")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Basic.jpg"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsImageText"))
        if @file_asset.datastreams.include?("Basic.jpg")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Basic.jpg"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsAudio"))
        if @file_asset.datastreams.include?("ACCESS_MP3")
          send_file(convert_url_to_local_path(@file_asset.datastreams["ACCESS_MP3"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsAudioText"))
        if @file_asset.datastreams.include?("ACCESS_MP3")
          send_file(convert_url_to_local_path(@file_asset.datastreams["ACCESS_MP3"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsWP"))
        if @file_asset.datastreams.include?("Basic.jpg")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Basic.jpg"].dsLocation))
        end
      end

      if (mapped_model_names.include?("info:fedora/afmodel:TuftsPdf"))
        if @file_asset.datastreams.include?("Archival.pdf")
          send_file(convert_url_to_local_path(@file_asset.datastreams["Archival.pdf"].dsLocation))
        end
      end
      # else
      #   flash[:notice]= "You do not have sufficient access privileges to download this document, which has been marked private."
      #   redirect_to(:action => 'index', :q => nil , :f => nil)
      # end
    end
  end

end
