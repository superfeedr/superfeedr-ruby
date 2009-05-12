class SubscribeQueryStanza < IqQueryStanza
  
  def initialize(params)
    super(params.merge({:type => :set}))
    pubsub = Nokogiri::XML::Node.new("pubsub", @doc)
    pubsub["xmlns"] = "http://jabber.org/protocol/pubsub"
    subscribe = Nokogiri::XML::Node.new("subscribe", @doc)
    subscribe["node"] = params[:node]
    subscribe["jid"] = from.split("/").first
    pubsub.add_child(subscribe)
    @iq.add_child(pubsub)
  end 
  
  def node
    @iq.search("subscribe").first["node"]
  end
  
end