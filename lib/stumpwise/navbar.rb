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

module Stumpwise
  class Navbar
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper

    attr_reader :accepts_contributions, :contribute_url, :controller
    attr_accessor :output_buffer

    def initialize(site, logged_in, controller)
      @site = site
      @accepts_contributions = site.can_accept_contributions?
      @contribute_url = site.contribute_url
      @logged_in = logged_in
      @controller = controller
    end

    def config
      controller.config
    end

    def logged_in?
      !!@logged_in
    end

    def header_markup
      load_stylesheets + load_jquery + load_javascript
    end

    def body_markup
      add_navbar_markup + initialize_campaign_site + load_analytics_javascript
    end

    private
      def load_stylesheets
        result = <<-BLOCK
          #{stylesheet}
          <!--[if lt IE 9]>#{ie_stylesheet}<![endif]-->
        BLOCK
        result.html_safe
      end

      def load_jquery
        "<script>!window.jQuery && document.write('<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js\"><\\/script>')</script>".html_safe
      end

      def load_javascript
        result = <<-BLOCK
          <!-- Setup Primary Google Analytics account -->
          <script>var _gaq = [['_setAccount','UA-15839704-1']];</script>

          #{javascript}
    		  <!--[if lt IE 9]>#{ie_javascript}<![endif]-->
    		BLOCK
    		result.html_safe
      end

      def add_navbar_markup
        content_tag :div, :id => 'stumpwise-bar' do
          result = stumpwise_tag + ' ' + admin_tag + ' ' + join_tag
          if @site.can_accept_contributions?
            result += ' '
            result += contribute_tag
          end
          result
        end
      end

      def stumpwise_tag
        link_to 'http://stumpwise.com', :class => "stumpwise-bar-button", :id => "stumpwise-bar-logo" do
          image_tag "navbar/logo.png", :class => "stumpwise-bar-button-img", :alt => "Powered by Stumpwise"
        end
      end

      def admin_tag
        link_to '/admin', :class => "stumpwise-bar-button", :id => "stumpwise-bar-admin" do
          if logged_in?
            image_tag "navbar/dashboard.png", :class => "stumpwise-bar-button-img"
          else
            image_tag "navbar/login.png", :class => "stumpwise-bar-button-img"
          end
        end
      end

      def join_tag
        link_to '/join', :class => "stumpwise-bar-button", :id => "stumpwise-bar-join" do
          image_tag "navbar/join.png", :class => "stumpwise-bar-button-img"
        end
      end

      def contribute_tag
        link_to @site.contribute_url, :class => "stumpwise-bar-button", :id => "stumpwise-bar-contribute" do
          image_tag "navbar/contribute.png", :class => "stumpwise-bar-button-img"
        end
      end

      def initialize_campaign_site
        result = <<-BLOCK
          <script>
            $(document).ready(function(){
              $(this).campaignSite({#{initialization_opts}});
              SW.trackPageview();
            });
          </script>
        BLOCK
        result.html_safe
      end

      def initialization_opts
        "subdomain:'#{@site.subdomain}'".tap do |opts|
          opts << ", customDomain:'#{@site.custom_domain}'" if @site.custom_domain.present?
          opts << ", analytics:'#{@site.google_analytics_id}'" if @site.google_analytics_id.present?
        end
      end

      def load_analytics_javascript
        result = <<-BLOCK
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
        result.html_safe
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