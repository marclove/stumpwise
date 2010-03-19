class SiteDrop < BaseDrop
  liquid_attributes.push(*[
    :name, :subhead, :keywords, :description, :disclaimer, :root_url,
    :public_email, :public_phone, :twitter_username, :facebook_page_id,
    :flickr_username, :youtube_username, :google_analytics_id, :contribute_url
  ])
end