class UnsubscribeQueryStanza < IqQueryStanza
  
  def initialize(params)
    super(params.merge({:type => :set}))
    pubsub = Nokogiri::XML::Node.new("pubsub", @doc)
    pubsub["xmlns"] = "http://jabber.org/protocol/pubsub"
    @iq.add_child(pubsub)
    unsubscribe = Nokogiri::XML::Node.new("unsubscribe", @doc)
    unsubscribe["node"] = params[:node].to_s
    unsubscribe["jid"] = from.split("/").first
    pubsub.add_child(unsubscribe)
  end 
  
  def node
    @iq.search("unsubscribe").first["node"]
  end
  
end