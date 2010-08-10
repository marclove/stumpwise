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
    theme_version.colors.keys
  end
  
  def text_keys
    theme_version.texts.keys
  end
  
  def if_keys
    theme_version.ifs.keys
  end
  
  def image_keys
    theme_version.images.keys
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