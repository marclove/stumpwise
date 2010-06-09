class ExistingContributionsAsLegacy < ActiveRecord::Migration
  def self.up
    add_column :contributions, :legacy, :boolean, :default => false

    begin
      Contribution.reset_column_information
      Contribution.transaction do
        Contribution.all.each{ |c| c.toggle!(:legacy) }
        Contribution.approved.each do |c|
          c.send(:add_amount_to_net)
          c.update_attribute(:status, 'settled')
        end
      end
    rescue
    end
  end

  def self.down
    remove_column :contributions, :legacy
  end
end
