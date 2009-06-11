class SubscribeQueryStanza < IqQueryStanza 
  
  def initialize(params) 
    raise NoFeedToSubscribe if params[:nodes].nil? or params[:nodes].empty? 
    raise TooManyFeeds if params[:nodes].size > 30 
    super(params.merge({:type => :set})) 
    @pubsub = Nokogiri::XML::Node.new("pubsub", @doc) 
    @pubsub["xmlns"] = "http://jabber.org/protocol/pubsub" 
    params[:nodes].each do |node| 
      add_node(node) 
    end 
    @iq.add_child(@pubsub) 
  end 
  
  def add_node(node)
    subscribe = Nokogiri::XML::Node.new("subscribe", @doc)
    subscribe["node"] = node
    subscribe["jid"] = from.split("/").first
    @pubsub.add_child(subscribe)
  end
  
  def nodes
    @pubsub.children.map {|c| c["node"]}
  end
  
end