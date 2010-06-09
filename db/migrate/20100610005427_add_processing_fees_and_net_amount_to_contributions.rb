class AddProcessingFeesAndNetAmountToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :processing_fees, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :contributions, :net_amount,      :decimal, :precision => 8, :scale => 2, :default => 0

    begin
      Contribution.reset_column_information
      Contribution.transaction do
        Contribution.approved.each{|c| c.increment_processing_fees }
      end
    rescue
    end
  end

  def self.down
    remove_column :contributions, :processing_fees
    remove_column :contributions, :net_amount
  end
end
