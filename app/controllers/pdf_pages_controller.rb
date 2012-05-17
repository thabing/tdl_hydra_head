class PdfPageController < ApplicationController

  def convert_url_to_local_path(url)
    local_object_store = Settings.local_object_store

    if local_object_store.match(/^\#\{Rails.root\}/)
      local_object_store = "#{Rails.root}" + local_object_store.gsub("\#\{Rails.root\}", "")
    end

    url = local_object_store << url.gsub(Settings.trim_bucket_url, "")
    url = url.gsub('archival_pdf','access_pdf_pageimages')
    return url
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
      pdf_pages = Settings.pdfpages.pagelocation
      #file name format PB.002.001.00001-0.png
      # pid-pagenumber.png
      # /pdf_pages/data05/tufts/central/dca/PB/access_pdf_pageimages/PB.002.001.00001

      send_file(convert_url_to_local_path(@file_asset.datastreams["Archival.pdf"].dsLocation))
    end
  end

end
