class BlogDrop < ItemDrop  
  def id
    @source.id
  end

  def html_id
    "blog-#{@source.id}"
  end
end