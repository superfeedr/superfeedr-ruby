class IqQueryStanza
  
  def initialize(params =  {})
    @doc = Nokogiri::XML::Document.new
    @iq = Nokogiri::XML::Node.new("iq", @doc)
    @iq["type"] = params[:type].to_s
    @iq["to"] = "firehoser.superfeedr.com"
    @iq["id"] = "#{random_iq_id}"
    @iq["from"] = params[:from] if params[:from]
  end
  
  def type
    @iq["type"]
  end
  
  def to
    @iq["to"]
  end
  
  def from
    @iq["from"]
  end
  
  def id
    @iq["id"]
  end
  
  def random_iq_id
    rand(1000)
  end
  
  def to_s
    @iq.to_s
  end
  
end