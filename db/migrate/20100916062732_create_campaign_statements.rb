class CreateCampaignStatements < ActiveRecord::Migration
  def self.up
    create_table :campaign_statements do |t|
      t.integer   :site_id
      t.date      :disbursed_on, :funds_available
      t.datetime  :starting, :ending
      t.decimal   :total_raised,  :precision => 8, :scale => 2, :default => 0
      t.decimal   :total_fees,    :precision => 8, :scale => 2, :default => 0
      t.decimal   :total_due,     :precision => 8, :scale => 2, :default => 0
      t.timestamps
    end
    
    add_index  :campaign_statements, :disbursed_on
    add_index  :campaign_statements, :site_id
    
    add_column :contributions, :campaign_statement_id, :integer
    add_index  :contributions, :campaign_statement_id
    add_column :contributions, :disbursed_on, :date
    add_index  :contributions, :disbursed_on
  end

  def self.down
    drop_table :campaign_statements
    remove_index  :contributions, :campaign_statement_id
    remove_column :contributions, :campaign_statement_id
  end
end
