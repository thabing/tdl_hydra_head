module TuftsFileAssetsHelper

  def send_datastream_inline(datastream)
      self.send_data datastream.content, :filename=>datastream.dsLabel, :type=>datastream.mimeType, :disposition => 'inline'
  end
end
