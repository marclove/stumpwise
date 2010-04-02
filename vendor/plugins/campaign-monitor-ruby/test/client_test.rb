require 'rubygems'
require 'lib/campaign_monitor'
require 'test/unit'
require 'test/test_helper'

CLIENT_NAME               = 'Spacely Space Sprockets'
CLIENT_CONTACT_NAME       = 'George Jetson'
LIST_NAME                 = 'List #1'

class CampaignMonitorTest < Test::Unit::TestCase
  
  def setup
    @cm = CampaignMonitor.new(ENV["API_KEY"])   
    # find an existing client and make sure we know it's values
    @client=find_test_client
    assert_not_nil @client, "Please create a '#{CLIENT_NAME}' (company name) client so tests can run."
  end
  
  
  def teardown
    # revert it back
    @client["ContactName"]="George Jetson"
    @client["EmailAddress"]="george@sss.com"
    
    @client["Username"]=""
    @client["Password"]=""
    @client["AccessLevel"]=0
    
    assert @client.update
    assert_success @client.result
  end
  
  # def test_create_and_delete_client
  #   before=@cm.clients.size
  #   client=CampaignMonitor::Client.new(build_new_client)
  #   client.Create
  #   assert_success client.result
  #   assert_equal before+1, @cm.clients.size 
  #   client.Delete
  #   assert_success client.result
  #   assert_equal before, @cm.clients.size
  # end
  
  def test_find_existing_client_by_name
    clients = @cm.clients
    assert clients.size > 0
    
    assert clients.map {|c| c.name}.include?(CLIENT_NAME), "could not find client named: #{CLIENT_NAME}"
  end
  
  def test_client_attributes
    assert_equal CLIENT_NAME, @client["CompanyName"]
    assert_nil @client["ContactName"]
    assert @client.GetDetail
    assert_not_empty @client["ContactName"]
    assert_not_empty @client["EmailAddress"]
    assert_not_empty @client["Country"]
    assert_not_empty @client["Timezone"]
    
    assert_nil @client["Username"]
    assert_nil @client["Password"]
    assert_equal 0, @client["AccessLevel"]
  end
  
  def test_update_client_basics
    # only update the name
    @client["ContactName"]="Bob Watson"
    assert @client.UpdateBasics
    assert_success @client.result
    client=@cm.clients.detect {|x| x.name==CLIENT_NAME}
    client.GetDetail
    assert_equal "Bob Watson", client["ContactName"]
    # make sure e-mail has remained unchanged
    assert_equal "george@sss.com", client["EmailAddress"]
  end
  
  def test_update_access_and_billing
    @client["Username"]="login"
    @client["Password"]="secret"
    @client["AccessLevel"]=63
    @client["BillingType"]="ClientPaysAtStandardRate"
    @client["Currency"]="USD"
    @client.UpdateAccessAndBilling
    assert_success @client.result
    # load it up again
    client=@cm.clients.detect {|x| x.name==CLIENT_NAME}
    client.GetDetail
    assert_equal "login", client["Username"]
    assert_equal "secret", client["Password"]
    assert_equal "ClientPaysAtStandardRate", client["BillingType"]
    assert_equal 63, client["AccessLevel"]
    assert_equal "USD", client["Currency"]
  end
  
  def test_update_both
    @client["ContactName"]="Bob Watson"
    @client["Username"]="login"
    @client["Password"]="secret"
    @client["AccessLevel"]=63
    @client["BillingType"]="ClientPaysAtStandardRate"
    @client["Currency"]="USD"
    @client.update
    assert_success @client.result
    assert_equal "login", @client["Username"]
    assert_equal "Bob Watson", @client["ContactName"]
  end
  
  
  protected
    def build_new_client(options={})
      {"CompanyName" => "Lick More Enterprises", "ContactName" => "George Jetson", 
        "EmailAddress" => "george@jetson.com", "Country" => "United States of America",
        "TimeZone" => "(GMT-05:00) Indiana (East)"
        }.merge(options)
    end
  

    def assert_success(result)
      assert result.succeeded?, result.message      
    end
    
    def find_test_client(clients=@cm.clients)
      clients.detect { |c| c.name == CLIENT_NAME }
    end
    
    def find_test_list(lists=find_test_client.lists)
      lists.detect { |l| l.name == LIST_NAME }
    end
end