module TuftsFileAssetsHelper

  def send_datastream_inline(datastream)
      content = datastream.content

      response.header["Content-Length"] = (datastream.size == 0) ? content.to_s.bytesize.to_s : datastream.size

      self.send_data content, :filename=>datastream.dsLabel, :type=>datastream.mimeType, :disposition => 'inline'
  end
end
