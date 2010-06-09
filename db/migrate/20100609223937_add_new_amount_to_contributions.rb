class AddNewAmountToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :new_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    
    begin
      Contribution.reset_column_information
      Contribution.transaction do
        Contribution.all.each{|c| c.update_attribute(:new_amount, c.amount / 100.0)}
      end
    rescue
    end
  end

  def self.down
    remove_column :contributions, :new_amount
  end
end
