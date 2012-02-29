# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    %w(jpg jpeg gif png JPG JPEG GIF PNG)
  end
  
  private
    def full_filename(for_file)
      fn, ext = for_file.split('.')[0..-2].join('.'), for_file.split('.')[-1..-1]
      [[fn, version_name].compact.join('_'), ext].join('.')
    end
end
