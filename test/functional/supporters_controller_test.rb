require 'test_helper'

class SupportersControllerTest < ActionController::TestCase
  context "Supporters Controller" do
    context "on POST to :create for inactive site" do
      setup do
        @request.env["HTTP_REFERER"] = "http://demo.localdev.com"
        setup_session_domain
        on_site(:inactive)
        post :create, :supporter => {:email => "newsupporter@stumpwise.com", :postal_code => '95123'}
      end
      
      should_respond_with(404)
    end
    
    context "on POST to :create" do
      setup do
        @request.env["HTTP_REFERER"] = "http://demo.localdev.com"
        setup_session_domain
        on_site(:with_content)
      end

      context "with a valid supporter attributes" do
        setup do
          post :create, :supporter => {:email => "newsupporter@stumpwise.com", :postal_code => '95123'}
        end
        
        should_respond_with :redirect
        should_create :supporter
        should_create :supportership
        should_assign_to :supporter
        should_assign_to :supportership
        
        should_change "the number of supporters for the current site", :by => 1 do
          sites(:with_content).supporters.count
        end
        
        should "set the supportership's receive_email attribute to true" do
          assert assigns(:supportership).receive_email
        end
      end
      
      context "with invalid supporter attributes" do
        setup do
          post :create, :supporter => {}
        end
        
        should_respond_with :redirect
        should_not_change("the number of supporters") { Supporter.count }
        should_not_change("the number of supporterships") { Supportership.count }
        should_not_assign_to :supporter
        should_not_assign_to :supportership
      end
      
      context "with a supporter that already exists for another site" do
        setup do
          post :create, :supporter => { :email => supporters(:other_site_supporter).email }
        end
        
        should_respond_with :redirect
        should_not_change("the number of supporters") { Supporter.count }
        should_create :supportership
        should_assign_to(:supporter) { supporters(:other_site_supporter) }
        should_assign_to :supportership
        
        should_change "the number of supporters for the current site", :by => 1 do
          sites(:with_content).supporters.count
        end

        should "set the supportership's receive_email attribute to true" do
          assert assigns(:supportership).receive_email
        end
      end
      
      context "with a supporter that already exists for the current site" do
        setup do
          post :create, :supporter => { :email => supporters(:with_content_supporter_1).email }
        end
        
        should_respond_with :redirect
        should_not_change("the number of supporters") { Supporter.count }
        should_not_change("the number of supporterships") { Supportership.count }
        should_assign_to :supporter
        should_assign_to :supportership
      end
    end
  end
end
