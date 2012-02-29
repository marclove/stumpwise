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

class CandidatePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :s3
  
  def default_url
    "/images/fallback/" + [version_name, "profile.png"].compact.join('_')
  end
  
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
