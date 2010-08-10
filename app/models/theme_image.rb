class ThemeImage
  include MongoMapper::EmbeddedDocument
  plugin Joint
  
  key :name, String, :required => true
  attachment :file
  
  def url
    "/gridfs/#{file_id}/#{URI.encode(file_name)}"
  end
end