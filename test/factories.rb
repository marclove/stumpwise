Factory.define :user do |u|
  u.email "tony@anthonywoodsforcongress.com"
  u.first_name "Anthony"
  u.last_name "Woods"
  u.password "test1234"
  u.password_confirmation "test1234"
  u.time_zone "Pacific Time (US & Canada)"
end

Factory.define :site do |s|
  s.subdomain "tonywoods"
  s.theme_id 1
  s.name "Anthony Woods"
  s.campaign_legal_name "Anthony Woods For Congress"
  s.campaign_email "tony@anthonywoodsforcongress.com"
  s.time_zone "Pacific Time (US & Canada)"
  s.owner_id 1
end

Factory.define :theme do |t|
  t.name "Theme 1"
end