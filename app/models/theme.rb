class Theme
  include MongoMapper::Document
  
  key :name,        String, :required => true
  key :version_ids, Array
  key :listed,      Boolean, :default => false
  timestamps!
  
  many :versions, :class_name => 'ThemeVersion',
                  :dependent => :destroy
  
  many :customizations, :class_name => 'ThemeCustomization',
                        :dependent => :destroy
  
  def latest_version
    versions.first({:active => true, :order => 'created_at desc'})
  end
  
  def destroy
    in_use? ? false : super
  end
  
  private
    def in_use?
      Site.find(:all, :conditions => {:mongo_theme_id => self.id.to_s}).size > 0
    end
end