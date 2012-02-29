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

require 'uuidtools'

class CreateCampaignMonitorClientJob < Struct.new(:site)
  def perform
    if client_id = create_client(site)
      create_supporter_list(site, client_id)
      create_contributor_list(site, client_id)
    end
  end

  def create_client(site)
    site.update_attribute(:campaign_monitor_password, UUIDTools::UUID.random_create.to_s[0..7])
    timezone = CreateSend::CreateSend.get('/timezones.json').parsed_response.select{|t| t.include?(site.time_zone)}.try(:first)

    client_id = CreateSend::Client.create(
      site.campaign_legal_name, site.owner.name, site.campaign_email,
      timezone, "United States of America"
    )
    @client = CreateSend::Client.new(client_id)
    @client.set_access(site.subdomain, site.campaign_monitor_password, 47)
    @client.set_payg_billing('USD', false, true, 0)
    client_id
  end
  
  def create_supporter_list(site, client_id)
    supporter_list_id = CreateSend::List.create(client_id, 'Supporters', '', false, '')
    site.update_attribute(:supporter_list_id, supporter_list_id)
  end
  
  def create_contributor_list(site, client_id)
    contributor_list_id = CreateSend::List.create(client_id, 'Contributors', '', false, '')
    site.update_attribute(:contributor_list_id, contributor_list_id)
  end
end