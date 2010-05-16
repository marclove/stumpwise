class SetCreatorAndUpdaterOnExistingItems < ActiveRecord::Migration
  def self.up
    Item.all.each do |i|
      i.update_attribute(:created_by, i.site.owner_id)
      i.update_attribute(:updated_by, i.site.owner_id)
    end
  end

  def self.down
  end
end
