require "babylon"
require "nokogiri"
require "stanzas/iq_query_stanza.rb"
require "stanzas/notification_stanza.rb"
require "stanzas/subscribe_query_stanza.rb"
require "stanzas/unsubscribe_query_stanza.rb"
require "stanzas/subscriptions_query_stanza.rb"

##
# Based on the API documented there : http://superfeedr.com/documentation
module Superfeedr
  
  class NotConnected < StandardError; end
  
  @@connection = nil
  @@callbacks = {}
  @@connection_callback = nil
  @@notication_callback = nil
  
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
        Babylon::ClientConnection.connect(params, self) 
      else 
        Babylon::ComponentConnection.connect(params, self) 
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
  # Subscribe to a feed. The block passed in argument will be called upon success. The block will take one boolen argument  : true means everything went right... false means something failed! (Please set Babylon's log to Log4r::INFO for more info)
  def self.subscribe(feed_url, &block)
    raise NotConnected unless connection
    stanza = SubscribeQueryStanza.new({:node => feed_url, :from => connection.jid})
    @@callbacks[stanza.id] = Proc.new { |stanza|
      block.call(stanza["type"] == "result")
    }
    send(stanza)
  end
  
  ## 
  # Unsubscribe from a feed. The block passed in argument will be called upon success. The block will take one boolen argument  : true means everything went right... false means something failed! (Please set Babylon's log to Log4r::INFO for more info)
  def self.unsubscribe(feed_url, &block)
    raise NotConnected unless connection
    stanza = UnsubscribeQueryStanza.new({:node => feed_url, :from => connection.jid})
    @@callbacks[stanza.id] = Proc.new { |stanza|
      block.call(stanza["type"] == "result")
    }
    send(stanza)
  end
  
  ##
  # Lists the subscriptions by page. The block passed in argument will be called with 2 arguments : the page, and an array of the feed's url in the page you requested. (Currently the Superfeedr API only supports 30 feeds per page.)
  def self.subscriptions(page = 1, &block)
    raise NotConnected unless connection
    stanza = SubscriptionsQueryStanza.new({:page => page, :from => connection.jid})
    @@callbacks[stanza.id] = Proc.new { |stanza|
      block.call(stanza.at("subscriptions")["page"].to_i, stanza.search("subscription").map { |s| s["node"] })
    }
    send(stanza)
  end
  
  ##
  # Specifies the block that will be called upon notification. Your block should take a NotificationStanza instance argument.
  def self.on_notification(&block)
    @@notication_callback = block
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
      @@callbacks[stanza["id"]].call(stanza)
      @@callbacks.delete(stanza["id"])
    elsif stanza.name == "message" and stanza.at("event")["xmlns"] == "http://jabber.org/protocol/pubsub#event"
      @@notication_callback.call(NotificationStanza.new(stanza))
      # Here we need to call the main notification callback!
    end
  end
  
end