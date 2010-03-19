class CreatePages < ActiveRecord::Migration
  def self.up
    add_column :items, :body, :text
  end

  def self.down
    remove_column :items, :body
  end
end
