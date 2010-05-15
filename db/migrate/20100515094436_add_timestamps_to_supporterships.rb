class AddTimestampsToSupporterships < ActiveRecord::Migration
  def self.up
    change_table :supporterships do |t|
      t.timestamps
    end
    Supportership.reset_column_information
    Supportership.all.each{|s| s.update_attributes(:created_at => s.supporter.created_at)}
  end

  def self.down
    remove_column :supporterships, :created_at
    remove_column :supporterships, :updated_at
  end
end
