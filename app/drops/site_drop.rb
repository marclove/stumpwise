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
end