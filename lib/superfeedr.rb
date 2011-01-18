require "skates"
require "yaml"
require "stanzas/iq_query_stanza.rb"
require "stanzas/notification_stanza.rb"
require "stanzas/subscribe_query_stanza.rb"
require "stanzas/unsubscribe_query_stanza.rb"
require "stanzas/subscriptions_query_stanza.rb"

##
# By default, the log level is at error. You can change that at anytime in your app
Skates.logger.level = Log4r::ERROR

##
# Based on the API documented there : http://superfeedr.com/documentation
module Superfeedr
  
  class NotConnected < StandardError; end
  
  @@connection = nil
  @@callbacks = {}
  @@connection_callback = nil
  @@notification_callback = nil
  
  ##
  # Connects your client to the Superfeedr.com XMPP server. You need to pass the following arguments :
  # "jid" : login@superfeedr.com
  # "password" : your superfeedr.com password
  # ["host" : host for your jid or component : only useful if you use an external jid ]
  # ["port" : port for your jid or component : only useful if you use an external jid ]
  # ["app_type" : (client | component) only useful if you use an external jid ]
  # The optional block will be called upon connection.
  def self.connect(jid, password, host = nil, port = nil, app_type = "client", &block)

    params = {
      "jid" => jid,
      "password" => password,
      "host" => host,
      "port" => port
    }
    @@connection_callback = block
    
    run = Proc.new {
      if app_type == "client"
        Skates::ClientConnection.connect(params, self) 
      else 
        Skates::ComponentConnection.connect(params, self) 
      end          
    }
    
    if EventMachine.reactor_running?
      run.call
    else
    EventMachine.run {
      run.call
    }
    end
  end
  
  ##
  # Subscribes to the multiple feeds, 30 by 30. Calls the block after each set of 30 feeds.
  def self.subscribe(*feeds, &block)
    return if feeds.flatten! == []
    subset = feeds.slice!(0..29)
    Superfeedr.add_feeds(subset) do |result|
      subscribe(feeds, &block)
      block.call(subset) 
    end
  end
  
  ##
  # Ubsubscribe to multiple feeds, one by one.  Calls the block after each set of 30 feeds.
  def self.unsubscribe(*feeds, &block)
    return if feeds.flatten! == []
    subset = feeds.slice!(0..29)
    Superfeedr.remove_feeds(subset) do |result|
      unsubscribe(feeds, &block)
      block.call(subset) 
    end
  end
  
  ##
  # List all subscriptions, by sending them by blocks (page), starting at page specified in argument
  def self.subscriptions(start_page = 1, &block)
    Superfeedr.subscriptions_by_page(start_page) do |page, result|
      if !result.empty?
        subscriptions(start_page + 1, &block)
      end
      block.call(page, result)
    end
  end
  
  ##
  # Adds the url to the list of feeds you're monitoring. The block passed in argument will be called upon success. 
  # The block will take one boolen argument : true means everything went right... false means something failed! 
  # (Please set Skates's log to Log4r::INFO for more info)
  def self.add_feeds(feeds_url, &block)
    raise NotConnected unless connection
    stanza = SubscribeQueryStanza.new({:nodes => feeds_url, :from => connection.jid})
    @@callbacks[stanza.id] = Hash.new
    @@callbacks[stanza.id][:method] = method(:on_subscribe)
    @@callbacks[stanza.id][:param] = block
    send(stanza)
  end
  
  ## 
  # Unsubscribe from a feed. The block passed in argument will be called upon success. 
  # The block will take one boolen argument  : true means everything went right... false means something failed! 
  # (Please set Skates's log to Log4r::INFO for more info)
  def self.remove_feeds(feeds_url, &block)
    raise NotConnected unless connection
    stanza = UnsubscribeQueryStanza.new({:nodes => feeds_url, :from => connection.jid})
    @@callbacks[stanza.id] = Hash.new
    @@callbacks[stanza.id][:method] = method(:on_unsubscribe)
    @@callbacks[stanza.id][:param] = block
    send(stanza)
  end
  
  ##
  # Lists the subscriptions by page. The block passed in argument will be called with 2 arguments : the page, 
  # and an array of the feed's url in the page you requested. 
  # (Currently the Superfeedr API only supports 30 feeds per page.)
  def self.subscriptions_by_page(page = 1, &block)
    raise NotConnected unless connection
    stanza = SubscriptionsQueryStanza.new({:page => page, :from => connection.jid})
    @@callbacks[stanza.id] = Hash.new
    @@callbacks[stanza.id][:method] = method(:on_subscriptions)
    @@callbacks[stanza.id][:param] = block
    send(stanza)
  end
  
  ##
  # Specifies the block that will be called upon notification. 
  # Your block should take a NotificationStanza instance argument.
  def self.on_notification(&block)
    @@notification_callback = block
  end
  
  ##
  # Called with a response to a subscriptions listing
  def self.on_subscriptions(stanza, &block)
    xmlns = {
      'pubsub' => 'http://jabber.org/protocol/pubsub',
      'superfeedr' => 'http://superfeedr.com/xmpp-pubsub-ext'
    }
    page = stanza.xpath('//pubsub:subscriptions/@superfeedr:page', xmlns).to_s.to_i
    feeds = stanza.xpath('//pubsub:subscription', xmlns).map { |s| CGI.unescapeHTML(s["node"]) }
    block.call(page, feeds)
  end
  
  ##
  # Called with a response to a subscribe
  def self.on_subscribe(stanza, &block)
    block.call(stanza["type"] == "result")
  end
  
  ##
  # Called with a response to an unsubscribe.
  def self.on_unsubscribe(stanza, &block)
    block.call(stanza["type"] == "result")
  end
  
  ##
  # ::nodoc::
  def self.callbacks
    @@callbacks
  end
  
  ##
  # ::nodoc::  
  def self.connection
    @@connection
  end
  
  ##
  # ::nodoc::
  def self.send(xml)
    connection.send_xml(xml)
  end
  
  ##
  # ::nodoc::
  def self.on_connected(connection) 
    @@connection = connection
    @@connection_callback.call
  end
  
  ##
  # ::nodoc::
  def self.on_disconnected()
    @@connection = false
  end
  
  ##
  # This shall not be called by your application. It is called upon stanza recetion. If it is a reply to a stanza we sent earlier, then, we just call it's associated callback. If it is a notification stanza, then, we call the notification callback (that you should have given when calling Superfeedr.connect) with a NotificationStanza instance.
  def self.on_stanza(stanza)
    if stanza["id"] && @@callbacks[stanza["id"]]
      @@callbacks[stanza["id"]][:method].call(stanza, &@@callbacks[stanza["id"]][:param])
      @@callbacks.delete(stanza["id"])
    else
      if stanza.name == "message" and !stanza.xpath("./ps:event", {"ps" => "http://jabber.org/protocol/pubsub#event"}).empty?
        @@notification_callback.call(NotificationStanza.new(stanza)) if @@notification_callback
        # Here we need to call the main notification callback!
      end
    end
  end
  
  ##
  # Config loaded from config.yaml
  def self.conf
    @@conf ||= YAML::load(File.read(File.dirname(__FILE__) + '/config.yaml'))
  end
  
  
end
