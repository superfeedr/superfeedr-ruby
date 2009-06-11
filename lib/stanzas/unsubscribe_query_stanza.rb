class UnsubscribeQueryStanza < IqQueryStanza
  
  def initialize(params)
    raise NoFeedToSubscribe if params[:nodes].nil? or params[:nodes].empty? 
    raise TooManyFeeds if params[:nodes].size > 30 
    super(params.merge({:type => :set}))
    
    @pubsub = Nokogiri::XML::Node.new("pubsub", @doc)
    params[:nodes].each do |node|
      add_node(node)
    end
    @pubsub["xmlns"] = "http://jabber.org/protocol/pubsub"
    @iq.add_child(@pubsub)
  end 
  
  def add_node(node)
    unsubscribe = Nokogiri::XML::Node.new("unsubscribe", @doc)
    unsubscribe["node"] = node.to_s
    unsubscribe["jid"] = from.split("/").first
    @pubsub.add_child(unsubscribe)
  end
  
  def nodes
    @pubsub.children.map {|c| c["node"]}
  end
  
end
