class AdminController < ApplicationController
  before_filter :handle_invalid_site,
                :require_authorized_user, 
                :require_acceptance_of_campaign_agreement
end