class CreateContributions < ActiveRecord::Migration
  def self.up
    create_table :contributions do |t|
      t.integer   :site_id
      t.string    :order_id
      t.timestamps
      t.string    :email
      t.integer   :amount
      t.string    :status
      t.string    :ip
      t.string    :employer
      t.string    :occupation
      t.boolean   :compliance_confirmation
      t.text      :compliance_statement
      t.string    :first_name
      t.string    :last_name
      t.string    :card_type
      t.string    :card_display_number
      t.integer   :card_month
      t.integer   :card_year
      t.string    :address1
      t.string    :address2
      t.string    :city
      t.string    :state
      t.string    :country
      t.string    :zip
      t.string    :phone
      t.boolean   :success
      t.boolean   :test
      t.boolean   :fraud_review
      t.text      :message
      t.string    :authorization
      t.text      :cvv_result
      t.text      :avs_result
    end
    
    add_index :contributions, :site_id
    add_index :contributions, :order_id, :unique => true
    add_index :contributions, :email
    add_index :contributions, :status
    add_index :contributions, [:last_name, :first_name]
    add_index :contributions, :success
  end

  def self.down
    drop_table :contributions
  end
end
