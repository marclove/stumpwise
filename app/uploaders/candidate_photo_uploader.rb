class CandidatePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :s3

  def store_dir
    "sites/#{model.id}/candidate"
  end

  version :t1 do
    process :resize_to_fit => [210, 10000]
  end

  def extension_white_list
    %w(jpg jpeg gif png JPG JPEG GIF PNG)
  end
  
  private
    def full_filename(for_file)
      fn, ext = for_file.split('.')[0..-2].join('.'), for_file.split('.')[-1..-1]
      [[fn, version_name].compact.join('_'), ext].join('.')
    end
end
