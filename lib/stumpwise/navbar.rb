module Stumpwise
  class Navbar
    attr_reader :accepts_contributions, :contribute_url
    def initialize(site)
      @site = site
      @accepts_contributions = site.can_accept_contributions?
      @contribute_url = site.contribute_url
    end
    
    def asset_base_url
      Rails.env.production? ? "http://stumpwise.com" : "http://localdev.com:3000"
    end

    def domain
      Rails.env.production? ? "null" : "'http://secure.localdev.com:3000'"
    end

    def stylesheet
      asset_base_url + "/stylesheets/stumpwise.css"
    end

    def javascript
      asset_base_url + "/javascripts/stumpwise.js"
    end
  end
end