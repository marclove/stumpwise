require 'faker'

default_theme = Theme.create(:name => "Default Theme")
default_theme.layouts.create(
  :filename => "layout.tpl",
  :content => File.new("#{RAILS_ROOT}/db/seeds/layout.tpl").readlines.join
)
default_theme.templates.create(
  :filename => "page.tpl",
  :content => File.new("#{RAILS_ROOT}/db/seeds/page.tpl").readlines.join
)
default_theme.templates.create(
  :filename => 'blog.tpl',
  :content => File.new("#{RAILS_ROOT}/db/seeds/blog.tpl").readlines.join
)
default_theme.templates.create(
  :filename => 'article.tpl',
  :content => File.new("#{RAILS_ROOT}/db/seeds/article.tpl").readlines.join
)

=begin
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/master.css", "text/css"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/grid.css", "text/css"))

default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/bg.jpg", "image/jpeg"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/footer_bg.gif", "image/gif"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/profile_drop_shadow_top.png", "image/png"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/profile_drop_shadow.png", "image/png"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/facebook_32.png", "image/png"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/flickr_32.png", "image/png"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/linkedin_32.png", "image/png"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/twitter_32.png", "image/png"))
default_theme.assets.create(:uploaded_data => ActionController::TestUploadedFile.new("#{RAILS_ROOT}/db/seeds/youtube_32.png", "image/png"))
=end

default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/master.css"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/grid.css"))

default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/bg.jpg"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/footer_bg.gif"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/profile_drop_shadow_top.png"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/profile_drop_shadow.png"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/facebook_32.png"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/flickr_32.png"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/linkedin_32.png"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/twitter_32.png"))
default_theme.assets.create(:file => File.open("#{RAILS_ROOT}/db/seeds/youtube_32.png"))


administrator =
  User.create(
    :first_name => "Marc",
    :last_name => "Love",
    :email => "marc.love@progressbound.com",
    :password => "marclove",
    :password_confirmation => "marclove"
  )
administrator.update_attribute(:super_admin, true)

candidate = 
  User.create(
    :first_name => "Evan",
    :last_name => "Low",
    :email => "evan@evanlow-local.com",
    :password => "trial198",
    :password_confirmation => "trial198"
  )

site = candidate.owned_sites.create(
    :subdomain => "evanlow",
    :custom_domain => "evanlow-local.com",
    :name => "Mayor Evan Low",
    :subhead => "Campbell City Council",
    :description => "",
    :keywords => "",
    :disclaimer => "Paid for and maintained by THE COMMITTEE TO RE-ELECT EVAN LOW",
    :facebook_page_id => "81588820822",
    :public_email => "evan@evanlow-local.com"
  )
site.update_attribute(:theme, default_theme)
site.update_attribute(:candidate_photo, File.open("#{RAILS_ROOT}/db/seeds/evan.jpg"))

Administratorship.create(:site => site, :administrator => candidate)

blog = Blog.create(
  :site => site,
  :title => "News", 
  :slug => 'news', 
  :template_name => 'blog.tpl', 
  :article_template_name => "article.tpl",
  :published => true,
  :show_in_navigation => true
)

10.times do |t|
  Article.create(
    :site_id => site.id,
    :parent_id => blog.id,
    :title => Faker::Lorem.words.join(" ").titleize,
    :body => "<p>" + Faker::Lorem.paragraphs(5).join("</p><p>") + "</p>",
    :created_at => Time.now - (10-t).days,
    :published => true
  )
end

Page.create(
  :site_id => site.id,
  :title => 'About Evan',
  :template_name => 'page.tpl',
  :body => File.new("#{RAILS_ROOT}/db/seeds/about-evan.html").readlines.join,
  :published => true,
  :show_in_navigation => true
)