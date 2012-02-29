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

class ThemeVersion
  include MongoMapper::Document
  plugin Joint

  key :theme_id, ObjectId, :required => true
  key :active,   Boolean, :default => false
  # key :major,    Integer, :default => 1, :required => true
  # key :minor,    Integer, :default => 0, :required => true
  # key :tiny,     Integer, :default => 0, :required => true
  key :code,     String, :default => ''
  key :colors,   Hash
  key :texts,    Hash
  key :ifs,      Hash
  key :images,   Hash
  attachment :thumbnail
  timestamps!
  
  ensure_index :theme_id
  ensure_index [[:theme_id, 1], [:active, 1], [:created_at, -1]]
  
  belongs_to :theme
  many :theme_assets
  
  # def version_string
  #   "#{major}.#{minor}.#{tiny}"
  # end
  
  def ifs=(ifs)
    new_ifs = ifs.inject({}) do |ifs, (k,v)|
      value = (v == 'true' || v == true)
      ifs[k] = value
      ifs
    end
    super(new_ifs)
  end
  
  def to_liquid
    {
      'name' => theme.name,
      #'version' => version_string,
      'color' => colors,
      'text' => texts,
      'if' => ifs,
      'image' => images
    }
  end
end