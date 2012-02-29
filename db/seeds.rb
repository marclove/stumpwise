# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'faker'

# Themes / Layouts / Theme Assets
ThemeAsset.delete_all
default_theme = Theme.create(:name => "Default Theme")
default_theme.layouts.create(
  :filename => "layout.tpl",
  :content => File.new("#{Rails.root}/db/seeds/layout.tpl").readlines.join
)
default_theme.templates.create(
  :filename => "page.tpl",
  :content => File.new("#{Rails.root}/db/seeds/page.tpl").readlines.join
)
default_theme.templates.create(
  :filename => 'blog.tpl',
  :content => File.new("#{Rails.root}/db/seeds/blog.tpl").readlines.join
)
default_theme.templates.create(
  :filename => 'article.tpl',
  :content => File.new("#{Rails.root}/db/seeds/article.tpl").readlines.join
)
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/master.css"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/grid.css"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/bg.jpg"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/footer_bg.gif"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/profile_drop_shadow_top.png"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/profile_drop_shadow.png"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/facebook_32.png"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/flickr_32.png"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/linkedin_32.png"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/twitter_32.png"))
default_theme.assets.create(:file => File.open("#{Rails.root}/db/seeds/youtube_32.png"))


# User Accounts
administrator = User.create(
  :first_name => "Marc",
  :last_name => "Love",
  :email => "marc.love@progressbound.com",
  :password => "marclove",
  :password_confirmation => "marclove",
  :time_zone => "Pacific Time (US & Canada)",
  :accepted_campaign_terms => true
)
administrator.update_attribute(:super_admin, true)
candidate = User.create(
  :first_name => "Anthony",
  :last_name => "Woods",
  :email => "tony@anthonywoods.com",
  :password => "test1234",
  :password_confirmation => "test1234",
  :time_zone => "Pacific Time (US & Canada)",
  :accepted_campaign_terms => true
)


# Sites
site = candidate.owned_sites.create(
  :subdomain => "woods",
  :name => "Anthony Woods",
  :subhead => "The Courage of Conviction",
  :description => "Iraq War veteran running for California's 10th Congressional District",
  :keywords => "Iraq War, Veterans, CA-10, Congress",
  :disclaimer => "Paid for and maintained by Anthony Woods For Congress",
  :facebook_page_id => "81588820822",
  :twitter_username => "woods4congress",
  :google_analytics_id => "UA-9999999-1",
  :candidate_photo => File.open("#{Rails.root}/db/seeds/anthonywoods.jpg"),
  :theme_id => 1,
  :eligibility_statement => "I am a United States citizen.",
  :campaign_legal_name => "Anthony Woods For Congress",
  :campaign_street => "2400 Market Street",
  :campaign_city => "San Francisco",
  :campaign_state => "CA",
  :campaign_zip => "94114",
  :campaign_email => "info@stumpwise-local.com",
  :campaign_phone => "415-555-1234",
  :time_zone => "Pacific Time (US & Canada)"
)

# Permissions
Administratorship.create(:site_id => 1, :administrator_id => 2)


# Site Content
blog = Blog.create(
  :site => site,
  :title => "News", 
  :slug => 'news', 
  :published => true,
  :show_in_navigation => true
)

8.times do |t|
  Article.create(
    :site => site,
    :parent => blog,
    :title => Faker::Lorem.words.join(" ").titleize,
    :body => "<p>" + Faker::Lorem.paragraphs(5).join("</p><p>") + "</p>",
    :created_at => Time.now - (10-t).days,
    :published => true
  )
end

Page.create(
  :site => site,
  :title => 'About Anthony',
  :body => File.new("#{Rails.root}/db/seeds/about.html").readlines.join,
  :published => true,
  :show_in_navigation => true
)

issues = Page.create(
  :site => site,
  :title => 'Issues',
  :body => "My issues are",
  :published => true,
  :show_in_navigation => true
)

Page.create(
  :site => site,
  :parent => issues,
  :title => 'Health Care',
  :body => "My position on health care",
  :published => true,
  :show_in_navigation => true
)

Page.create(
  :site => site,
  :parent => issues,
  :title => 'Veterans',
  :body => "My position on veterans",
  :published => true,
  :show_in_navigation => true
)

# Contributions & Transactions

# Supporters
