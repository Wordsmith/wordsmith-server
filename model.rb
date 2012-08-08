class Definition
  attr_reader :type, :text, :attribution
  
  def initialize(type, text, attribution)
    @type = type
    @text = text
	@attribution = attribution
  end
end

class Example
  attr_reader :title, :text, :rating, :url
  
  def initialize(title, text, rating, url)
    @title = title
    @text = text
	@rating = rating
	@url = url
  end
end
