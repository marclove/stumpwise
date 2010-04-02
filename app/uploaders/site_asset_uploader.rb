class SiteAssetUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :s3

  def store_dir
    "sites/#{model.site.id}/assets/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  #     def default_url
  #       "sites/defaults/" + [version_name, "candidate.png"].compact.join('_')
  #     end

  # Process files as they are uploaded.
  #     process :scale => [200, 300]
  #
  #     def scale(width, height)
  #       # do something
  #     end
  
  # Create different versions of your uploaded files
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
  
  # Add a white list of extensions which are allowed to be uploaded,
  # for images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  private
    def full_filename(for_file)
      fn, ext = for_file.split('.')[0..-2].join('.'), for_file.split('.')[-1..-1]
      [[fn, version_name].compact.join('_'), ext].join('.')
    end
end
