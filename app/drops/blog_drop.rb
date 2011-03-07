class BlogDrop < ItemDrop  
  def id
    @source.id
  end

  def html_id
    "blog-#{@source.id}"
  end
  
  def feed_url
    @source.to_url + '/feed'
  end
end