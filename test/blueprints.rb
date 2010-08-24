require 'machinist'
require 'machinist/active_record'
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
Sham.word_list      { Faker::Lorem::words(8).join(', ') }
Sham.template_name(:unique => false)  { "template.tpl" }
Sham.filename(:unique => false)       { "template.tpl" }
Sham.image { File.open("#{Rails.root}/test/fixtures/files/image.jpg") }
Sham.phone { Faker::PhoneNumber.phone_number }

Administratorship.blueprint do
  administrator { User.make }
  site { Site.make }
end

Article.blueprint do
  blog { Blog.make }
  title
  slug
  body
end

Asset.blueprint do
  site { Site.make }
  file { Sham.image }
end

Blog.blueprint do
  title
  template_name
  article_template_name { "article.tpl" }
  site { Site.make }
end

Contribution.blueprint do
  site { Site.make }
  email
  amount { 20.00 }
  first_name { Sham.name }
  last_name { Sham.name }
  address1 { Faker::Address.street_address }
  city { Faker::Address.city }
  state { Faker::Address.us_state_abbr }
  zip { Faker::Address.zip_code }
  country { "US" }
  employer { "Google" }
  occupation { "Programmer" }
end

Item.blueprint do
  title
  site { Site.make }
end

Page.blueprint do
  title
  template_name
  body
  site { Site.make }
end

Site.blueprint do
  owner { User.make }
  subdomain
  theme_id { 1 }
  name
  campaign_legal_name { Faker::Company.name }
  campaign_email { Sham.email }
  time_zone { "Pacific Time (US & Canada)" }
end

Site.blueprint(:complete) do
  owner { User.make }

  subdomain
  custom_domain
  theme_id { 1 }
  name
  subhead { Faker::Company.catch_phrase }
  keywords { Sham.word_list }
  description { Sham.body }
  disclaimer { Sham.body }
  candidate_photo { Sham.image }
  eligibility_statement { Faker::Lorem.paragraph }
  time_zone { "Pacific Time (US & Canada)" }
  
  campaign_legal_name { Faker::Company.name }
  campaign_street { Faker::Address.street_address }
  campaign_city { Faker::Address.city }
  campaign_state { Faker::Address.us_state_abbr }
  campaign_zip { Faker::Address.zip_code }
  campaign_email { Sham.email }
  campaign_phone { Faker::PhoneNumber.phone_number }

  twitter_username { Sham.username }
  facebook_page_id { "9483276492" }
  flickr_username { Sham.username }
  youtube_username { Sham.username }
  google_analytics_id { "UA-99999-1" }
  paypal_email { Sham.email }

  campaign_monitor_password { "abc123" }
  supporter_list_id { "12345678" }
  contributor_list_id { "87654321" }
end

Supporter.blueprint do
  first_name { Sham.name }
  last_name { Sham.name }
  phone { Faker.numerify("(###)###-####") }
  email { Sham.email }
  mobile_phone { Faker.numerify("(###)###-####") }
  postal_code { Faker::Address.zip_code }
end

Supportership.blueprint do
  supporter { Supporter.make }
  site { Site.make }
end

User.blueprint do
  email { Sham.email }
  first_name { Sham.name }
  last_name { Sham.name }
  password { "test1234" }
  password_confirmation { "test1234" }
  time_zone { "Pacific Time (US & Canada)" }
end  

User.blueprint(:admin) do
  email { Sham.email }
  first_name { Sham.name }
  last_name { Sham.name }
  password { "test1234" }
  password_confirmation { "test1234" }
  time_zone { "Pacific Time (US & Canada)" }
  super_admin { true }
end  
