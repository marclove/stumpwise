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

class SiteDrop < BaseDrop
  liquid_attributes.push(*[
    :name, :subhead, :keywords, :description, :disclaimer, :root_url,
    :campaign_email, :campaign_phone, :twitter_username, :facebook_page_id,
    :flickr_username, :youtube_username, :google_analytics_id, :contribute_url,
    :campaign_legal_name, :campaign_street, :campaign_city, :campaign_state,
    :campaign_zip
  ])
  
  def copyright
    "Copyright &copy; #{Time.now.year} #{@source['campaign_legal_name']}"
  end
  
  def candidate_photo
    @source.candidate_photo.t1.url if @source.candidate_photo
  end
  
  def navigation
    @source.navigation.map(&:to_liquid)
  end
  
  def accepts_contributions?
    @source.can_accept_contributions?
  end
  
  def google_analytics_code
    result = <<-CODE
    <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-15839704-1']);
      _gaq.push(['_setDomainName', 'none']);
      _gaq.push(['_setAllowLinker', true])
      _gaq.push(['_trackPageview']);
    CODE
    if !@source.google_analytics_id.blank? && !@source.custom_domain.blank?
      result += <<-CODE
      if ('#{@source.subdomain}.stumpwise.com' != document.location.hostname) {
        _gaq.push(['b._setAccount', '#{@source['google_analytics_id']}']);
        _gaq.push(['b._setDomainName', '.#{@source.domain}']);
        _gaq.push(['b._trackPageview']);
      }
      CODE
    end
    result += <<-CODE
      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();
    </script>
    CODE
  end
end