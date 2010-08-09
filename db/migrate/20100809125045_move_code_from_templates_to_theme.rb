class MoveCodeFromTemplatesToTheme < ActiveRecord::Migration
  def self.up
    add_column :themes, :code, :text
  end

  def self.down
    remove_column :themes, :code
  end
end
