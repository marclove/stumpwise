require 'test_helper'

class SupportersControllerTest < ActionController::TestCase
  context "With a site woods.localdev.com" do
    setup do
      Site.create!(:subdomain => "woods", :theme_id => Mongo::ObjectID.new)
      @request.host = "woods.localdev.com"
    end
    
    should "create a supporter on POST" do
      assert_difference 'Supporter.count' do
        post :create, :supporter => {
          :first_name => "Marc",
          :last_name => "Love",
          :email => "marc.love@progressbound.com"
        }
      end
    end
  end
end
