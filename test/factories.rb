Factory.define :user do |u|
  u.email "tony@anthonywoodsforcongress.com"
  u.first_name "Anthony"
  u.last_name "Woods"
  u.password "test1234"
  u.password_confirmation "test1234"
  u.time_zone "Pacific Time (US & Canada)"
end

Factory.define :site do |s|
  s.owner_id 1
  s.theme_id 1
  s.subdomain "tonywoods"
  s.name "Woods For Congress"
  s.subhead 'The Courage of Conviction'
  s.keywords 'Democrat, 10th Congressional District, Iraq War Vet'
  s.description 'Anthony Woods, Iraqi War Vet, running for California\'s 10th Congressional District'
  s.disclaimer 'Paid for by the Committee To Elect Anthony Woods'
  s.twitter_username 'woods4congress'
  s.facebook_page_id '123456789'
  s.flickr_username 'anthonywoods' 
  s.youtube_username 'anthonywoods'
  s.campaign_legal_name "Anthony Woods For Congress"
  s.campaign_street '123 Anywhere Street'
  s.campaign_city 'San Francisco'
  s.campaign_state 'CA'
  s.campaign_zip '95111'
  s.campaign_email "info@woodsforcongress.com"
  s.campaign_phone "(510) 555-5555"
  s.time_zone "Pacific Time (US & Canada)"
  s.active true
  s.can_accept_contributions true
end

Factory.define :site_with_analytics, :parent => :site do |s|
  s.subdomain "tonywoods2"
  s.google_analytics_id 'UA-99999-1'
end

Factory.define :site_with_custom_domain, :parent => :site do |s|
  s.subdomain "tonywoods3"
  s.custom_domain 'anthonywoods1.com'
end

Factory.define :site_with_custom_domain_and_analytics, :parent => :site do |s|
  s.subdomain "tonywoods4"
  s.google_analytics_id 'UA-99999-1'
  s.custom_domain 'anthonywoods2.com'
end

Factory.define :theme do |t|
  t.name "Theme 1"
end