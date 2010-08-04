module Stumpwise
  class Navbar
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    
    attr_reader :accepts_contributions, :contribute_url

    def initialize(site)
      @site = site
      @accepts_contributions = site.can_accept_contributions?
      @contribute_url = site.contribute_url
    end

    def domain
      Rails.env.production? ? "null" : "'http://secure.localdev.com:3000'"
    end
    
    def stylesheet
      stylesheet_link_tag('stumpwise.css')
    end
    
    def ie_stylesheet
      stylesheet_link_tag('stumpwise-ie.css')
    end
    
    def javascript
      '<script src="https://stumpwise.com/javascripts/stumpwise.js?1280825985" type="text/javascript"></script>'
    end
    
    def ie_javascript
      javascript_include_tag('stumpwise-ie.js')
    end
  end
end