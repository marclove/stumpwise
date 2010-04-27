class SiteAssetUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :s3

  def store_dir
    "sites/#{model.site.id}/assets/#{model.id}"
  end

  version :thumb do
    process :resize_to_fit => [50, 50]
  end
  
  version :small do
    process :resize_to_limit => [100, 100]
  end
  
  version :medium do
    process :resize_to_limit => [240, 240]
  end
  
  version :large do
    process :resize_to_limit => [480, 480]
  end
  
  version :xlarge do
    process :resize_to_limit => [600, 600]
  end
  
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  private
    def full_filename(for_file)
      fn, ext = for_file.split('.')[0..-2].join('.'), for_file.split('.')[-1..-1]
      [[fn, version_name].compact.join('_'), ext].join('.')
    end
end
