class CreateLiquidTemplates < ActiveRecord::Migration
  def self.up
    create_table :liquid_templates do |t|
      t.integer :theme_id, :null => false
      t.string  :type,     :null => false
      t.string  :filename, :null => false
      t.text    :content
      t.timestamps
    end
    
    add_index :liquid_templates, [:theme_id, :filename]
  end

  def self.down
    drop_table :liquid_templates
  end
end
