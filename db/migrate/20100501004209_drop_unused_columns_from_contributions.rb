class DropUnusedColumnsFromContributions < ActiveRecord::Migration
  def self.up
    change_table :contributions do |t|
      t.remove :success
      t.remove :fraud_review
      t.remove :message
      t.remove :authorization
      t.remove :avs_result
      t.remove :cvv_result
    end
  end

  def self.down
    change_table :contributions do |t|
      t.boolean   :success
      t.boolean   :fraud_review
      t.text      :message
      t.string    :authorization
      t.text      :cvv_result
      t.text      :avs_result
    end
  end
end
