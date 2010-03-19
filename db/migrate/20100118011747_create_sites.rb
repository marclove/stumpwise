class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.timestamps
      t.string  :subdomain      # woods
      t.string  :custom_domain  # woodsforcongress.com
      t.integer :theme_id
      t.string  :name, :subhead
      t.text    :keywords, :description, :disclaimer
      t.string  :public_email
      t.string  :public_phone
      t.string  :twitter_username
      t.integer :facebook_page_id
      t.string  :flickr_username
      t.string  :youtube_username
      t.string  :google_analytics_id
      t.string  :paypal_email
    end

    add_index :sites, :subdomain, :unique => true
    add_index :sites, :custom_domain, :unique => true
  end

  def self.down
    drop_table :sites
  end
end
