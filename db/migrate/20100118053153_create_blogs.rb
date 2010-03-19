class CreateBlogs < ActiveRecord::Migration
  def self.up
    add_column :items, :article_template_name, :string
  end

  def self.down
    remove_column :items, :article_template_name
  end
end
