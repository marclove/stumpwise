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

class ThemeCustomization
  include MongoMapper::Document

  key :site_id,           Integer,  :required => true
  key :theme_id,          ObjectId, :required => true
  key :theme_version_id,  ObjectId, :required => true
  key :colors,            Hash
  key :texts,             Hash
  key :ifs,               Hash
  timestamps!
  
  belongs_to :theme
  belongs_to :theme_version
  many :theme_images
  
  def self.generate(site_id, theme_id, theme_version_id=nil)
    ThemeCustomization.create({
      :site_id => site_id,
      :theme_id => theme_id,
      :theme_version_id => theme_version_id ? theme_version_id : Theme.find(theme_id).versions.last.id
    })
  end
  
  def ifs=(ifs)
    new_ifs = ifs.inject({}) do |ifs, (k,v)|
      value = (v == 'true' || v == true)
      ifs[k] = value
      ifs
    end
    super(new_ifs)
  end
  
  def color_keys
    theme_version.colors.keys.sort
  end
  
  def text_keys
    theme_version.texts.keys.sort
  end
  
  def if_keys
    theme_version.ifs.keys.sort
  end
  
  def image_keys
    theme_version.images.keys.sort
  end
  
  def merged_texts
    theme_version.texts.merge(self.texts)
  end
  
  def merged_colors
    theme_version.colors.merge(self.colors)
  end
  
  def merged_ifs
    theme_version.ifs.merge(self.ifs)
  end
  
  def images
    theme_images.inject({}) do |hash, i|
      hash[i.name] = i.url
      hash
    end
  end
  
  def to_liquid
    {
      'color' => colors,
      'text' => texts,
      'if' => ifs,
      'image' => images
    }
  end
  
  # def upgrade(version_id=nil)
  #   new_version = version_id ? theme.versions.find(version_id) : theme.latest_version
  #   self.theme_version = new_version
  #   update_customizations
  #   save
  # end
  
  def reset!
    self.colors = {}
    self.texts  = {}
    self.ifs    = {}
    self.theme_images = []
    self.save
  end

  private
    # def update_customizations
    #   # iterate through colors, texts, ifs & theme_images
    #   # for each, remove the key/value pairs that no longer exist on the parent
    #   # theme_version
    # end  
end