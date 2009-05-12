class SubscriptionsQueryStanza < IqQueryStanza
  
  def initialize(params)
    super(params.merge({:type => :get}))
    pubsub = Nokogiri::XML::Node.new("pubsub", @doc)
    pubsub["xmlns"] = "http://jabber.org/protocol/pubsub"
    @iq.add_child(pubsub)
    subscriptions = Nokogiri::XML::Node.new("subscriptions", @doc)
    subscriptions["page"] = params[:page].to_s
    subscriptions["jid"] = from.split("/").first
    pubsub.add_child(subscriptions)
  end
  
  def page
    @iq.search("subscriptions").first["page"]
  end
  
end