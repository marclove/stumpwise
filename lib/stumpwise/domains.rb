module Stumpwise
  module Domains
    def self.included(controller)
      controller.helper_method(:current_site)
    end
  
    protected
      def current_site
        @site ||=
          if custom_domain?
            Site.find_by_custom_domain(current_domain)
          elsif current_subdomain != 'www' && !current_subdomain.nil?
            Site.find_by_subdomain(current_subdomain)
          else
            nil
          end
      end
      
      def custom_domain?
        current_domain != BASE_URL
      end
  end
end