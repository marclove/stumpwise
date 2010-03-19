require 'machinist/mongo_mapper'
require 'sham'
require 'faker'

Sham.name   { Faker::Name.name }
Sham.email  { Faker::Internet.email }
Sham.title  { Faker::Lorem.words.join(' ').titleize }
Sham.body   { Faker::Lorem.paragraph }
Sham.slug   { ([Faker::Internet.domain_word]*3).join("-") }
Sham.username       { Faker::Internet.user_name }
Sham.custom_domain  { Faker::Internet.domain_name }
Sham.subdomain      { Faker::Internet.domain_word }
Sham.local_domain   { Faker::Internet.domain_word + BASE_URL }
Sham.word_list      { Faker::Lorem::words(8).join(', ') }
Sham.template_name(:unique => false)  { "template.tpl" }
Sham.filename(:unique => false)       { "template.tpl" }

Article.blueprint do
  blog { Blog.make }
  title
  slug
  body
end

Blog.blueprint do
  title
  slug
  template_name
  article_template_name { "article.tpl" }
  site { Site.make }
end

Layout.blueprint do
  filename
  content { Sham.body }
  theme { Theme.make }
end

Page.blueprint do
  title
  slug
  template_name
  body
  site { Site.make }
end

Site.blueprint do
  subdomain
  #custom_domain
  theme { Theme.make }
  name
  subhead { Faker::Lorem.sentence }
  keywords { Sham.word_list }
  description { Sham.body }
  disclaimer { Sham.body }
  public_email { Sham.email }
  public_phone { Faker::PhoneNumber.phone_number }
  twitter_username { Sham.username }
  facebook_page_id { "9483276492" }
  flickr_username { Sham.username }
  youtube_username { Sham.username }
  google_analytics_id { "UA-99999-1" }
end

Template.blueprint do
  filename
  content { Sham.body }
  theme { Theme.make }
end

Theme.blueprint do
  name
end

User.blueprint do
  first_name { Sham.name }
  last_name { Sham.name }
  email { Sham.email }
  password { "testing" }
  password_confirmation { "testing" }
end

Supporter.blueprint do
  first_name { Sham.name }
  last_name { Sham.name }
  email { Sham.email }
end