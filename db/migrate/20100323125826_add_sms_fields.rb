class AddSmsFields < ActiveRecord::Migration
  def self.up
    add_column :supporters, :mobile_phone, :string
    add_column :supporterships, :receive_sms, :boolean, :default => false
    change_column_default :supporterships, :receive_email, false
  end

  def self.down
    remove_column :supporters, :mobile_phone
    remove_column :supporterships, :receive_sms
  end
end
