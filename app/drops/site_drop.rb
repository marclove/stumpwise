class SiteDrop < BaseDrop
  liquid_attributes.push(*[
    :name, :subhead, :keywords, :description, :disclaimer, :root_url,
    :public_email, :public_phone, :twitter_username, :facebook_page_id,
    :flickr_username, :youtube_username, :google_analytics_id, :contribute_url
  ])
  
  def copyright
    "Copyright &copy; #{Time.now.year} #{@source['name']}"
  end
  
  def candidate_photo
    @source.candidate_photo.t1.url
  end
  
  def navigation
    @source.navigation &:to_liquid
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