class ArticleDrop < ItemDrop
  liquid_attributes.push(*[ :body ])
  
  def id
    @source.id
  end

  def blog
    @source.blog.to_liquid
  end
  
  def html_id
    "article-#{@source.id}"
  end
end
