module Stumpwise
  class Navbar
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper
    
    attr_reader :accepts_contributions, :contribute_url
    attr_accessor :output_buffer

    def initialize(site)
      @site = site
      @accepts_contributions = site.can_accept_contributions?
      @contribute_url = site.contribute_url
    end
    
    def header_markup
      load_stylesheets + load_jquery + load_javascript
    end
    
    def body_markup
      add_navbar_markup + initialize_campaign_site + load_analytics_javascript
    end
    
    private
      def load_stylesheets
        <<-BLOCK
          #{stylesheet}
          <!--[if lt IE 9]>#{ie_stylesheet}<![endif]-->
        BLOCK
      end
      
      def load_jquery
        "<script>!window.jQuery && document.write('<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js\"><\\/script>')</script>"
      end
    
      def load_javascript
        <<-BLOCK
          <!-- Setup Primary Google Analytics account -->
          <script>var _gaq = [['_setAccount','UA-15839704-1']];</script>
        
          #{javascript}
    		  <!--[if lt IE 9]>#{ie_javascript}<![endif]-->
    		BLOCK
      end
    
      def add_navbar_markup
        if @site.can_accept_contributions?
          content_tag :div, :id => 'stumpwise-bar' do
            self.output_buffer << "\n"
            link_to 'http://stumpwise.com', :class => "stumpwise-bar-button", :id => "stumpwise-bar-logo" do
              image_tag "navbar/logo.png", :class => "stumpwise-bar-button-img", :alt => "Powered by Stumpwise"
            end
            self.output_buffer << "\n"
            link_to '/join', :class => "stumpwise-bar-button", :id => "stumpwise-bar-join" do
              image_tag "navbar/join.png", :class => "stumpwise-bar-button-img"
            end
            self.output_buffer << "\n"
            link_to @site.contribute_url, :class => "stumpwise-bar-button", :id => "stumpwise-bar-contribute" do
              image_tag "navbar/contribute.png", :class => "stumpwise-bar-button-img"
            end
            self.output_buffer << "\n"
          end
        else
          content_tag :div, :id => 'stumpwise-bar' do
            self.output_buffer << "\n"
            link_to 'http://stumpwise.com', :class => "stumpwise-bar-button", :id => "stumpwise-bar-logo" do
              image_tag "navbar/logo.png", :class => "stumpwise-bar-button-img", :alt => "Powered by Stumpwise"
            end
            self.output_buffer << "\n"
            link_to '/join', :class => "stumpwise-bar-button", :id => "stumpwise-bar-join" do
              image_tag "navbar/join.png", :class => "stumpwise-bar-button-img"
            end
            self.output_buffer << "\n"
          end
        end
      end
    
      def initialize_campaign_site
        <<-BLOCK
          <script>
            $(document).ready(function(){
              $(this).campaignSite({#{initialization_opts}});
              SW.trackPageview();
            });
          </script>
        BLOCK
      end
    
      def initialization_opts
        "subdomain:'#{@site.subdomain}'".tap do |opts|
          opts << ", customDomain:'#{@site.custom_domain}'" if @site.custom_domain.present?
          opts << ", analytics:'#{@site.google_analytics_id}'" if @site.google_analytics_id.present?
        end
      end
    
      def load_analytics_javascript
        <<-BLOCK
          <script>
            (function(d, t){
            	var g = d.createElement(t),
            			s = d.getElementsByTagName(t)[0];
            	g.async = 1;
            	g.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            	s.parentNode.insertBefore(g, s);
            }(document, 'script'));
          </script>
        BLOCK
      end
    
      def stylesheet
        stylesheet_link_tag("http://#{HOST}/stylesheets/stumpwise.css")
      end
    
      def ie_stylesheet
        stylesheet_link_tag("http://#{HOST}/stylesheets/stumpwise-ie.css")
      end
    
      def javascript
        javascript_include_tag(
          "externals/mootools-1.2.4-base",
          "externals/Class.Mutators.jQuery",
          "externals/jquery.colorbox",
          "externals/jquery.ba-postmessage",
          "externals/jquery.timeago",
          "externals/jquery.validate",
          :cache => "stumpwise.externals"
        ) + "\n" +
        javascript_include_tag("stumpwise")
      end
    
      def ie_javascript
        javascript_include_tag "stumpwise-ie"
      end
  end
end