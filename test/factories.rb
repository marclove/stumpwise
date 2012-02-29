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