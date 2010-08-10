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