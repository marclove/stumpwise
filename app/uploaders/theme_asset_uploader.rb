class ThemeAssetUploader < CarrierWave::Uploader::Base
  storage :s3

  def store_dir
    "themes/#{model.theme_id}"
  end
end
