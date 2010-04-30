##
# Repesents the items published by the firehoser (the feed entries).
# They have accessors for the following fields :
# - title 
# - summary 
# - link
# - published
# - unique_id
# - chunks (long entries might be notified in several chunks)
# - chunk (current chunk out of chunks)
#
# <item xmlns="http://jabber.org/protocol/pubsub" chunks="2" chunk="1">
#     <entry xmlns="http://www.w3.org/2005/Atom" xml:lang="">
#         <title>cool</title>
#         <content type="text">cool</content>
#         <id>tag:pubhubsubbub-example-app,2009:ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw</id>
#         <published>2010-03-25T16:57:18Z</published>
#         <link type="text/html" href="http://pubsubhubbub-example-app.appspot.com/ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw" title="" rel="alternate"/>
#     </entry>
# </item>

require 'time'

class Link
  def initialize(node)
    @node = node
  end
  
  def title
    @node["title"]
  end
  
  def href
    @node["href"]
  end
  
  def rel
    @node["rel"]
  end
  
  def type
    @node["type"]
  end
  
end

class Author
  def initialize(node)
    @node = node
  end
  
  def name
    if !@name
      if name = @node.at_xpath("./atom:name", {"atom" => "http://www.w3.org/2005/Atom"})
        @name = name.text
      end
    end
  end
  
  def uri
    if !@uri
      if uri = @node.at_xpath("./atom:uri", {"atom" => "http://www.w3.org/2005/Atom"})
        @uri = uri.text
      end
    end
  end
  
  def email
    if !@email
      if email = @node.at_xpath("./atom:email", {"atom" => "http://www.w3.org/2005/Atom"})
        @email = email.text
      end
    end
  end
  
end

class Category
  def initialize(node)
    @node = node
  end
  
  def term
    @node["term"]
  end
end

class Location
  def initialize(node)
    @node = node
  end
  
  def point
    @point ||= @node.text
  end
  
  def lat
    @lat ||= point.split().first.to_f
  end
  
  def lon
    @lon ||= point.split().last.to_f
  end
  
end

class Item
  
  def initialize(node)
    @node = node
  end
  
  def title
    @title ||= @node.at_xpath("./atom:entry/atom:title", {"atom" => "http://www.w3.org/2005/Atom"}).text
  end
  
  def summary
    if !@summary
      if summary = @node.at_xpath("./atom:entry/atom:summary", {"atom" => "http://www.w3.org/2005/Atom"})
        @summary = summary.text
      end
    end
    @summary
  end

  def unique_id
    @unique_id ||= @node.at_xpath("./atom:entry/atom:id", {"atom" => "http://www.w3.org/2005/Atom"}).text
  end
  
  def published
    if !@published
      if published = @node.at_xpath("./atom:entry/atom:published", {"atom" => "http://www.w3.org/2005/Atom"}).text
        @published = Time.parse(published)
      end
    end
    @published
  end
  
  def chunks
    @node["chunks"].to_i
  end
  
  def chunk
    @node["chunk"].to_i
  end
  
  def links
    if !@links
      @links = []
      @node.xpath("./atom:entry/atom:link", {"atom" => "http://www.w3.org/2005/Atom"}).each do |node|
        @links.push(Link.new(node))
      end
    end
    @links
  end

  def authors
    if !@authors
      @authors = []
      @node.xpath("./atom:entry/atom:author", {"atom" => "http://www.w3.org/2005/Atom"}).each do |node|
        @authors.push(Author.new(node))
      end
    end
    @authors
  end

  def categories
    if !@categories
      @categories = []
      @node.xpath("./atom:entry/atom:category", {"atom" => "http://www.w3.org/2005/Atom"}).each do |node|
        @categories.push(Category.new(node))
      end
    end
    @categories
  end

  def locations
    if !@locations
      @locations = []
      @node.xpath("./atom:entry/georss:point", {"atom" => "http://www.w3.org/2005/Atom", "georss" => "http://www.georss.org/georss"}).each do |node|
        @locations.push(Location.new(node))
      end
    end
    @locations
  end
  
end


##
# Notification : sent every time a feed has been fetched. It has the following methods: 
# - message_status : a simple message that gives information about the last fetch
# - http_status : status of the http response
# - feed_url : url of the feed
# - next_fetch : Time when the feed will be fetched again (this is purely informative and it might change)
# - items : array of new items detected (might be empty)
#
# 
# <message xmlns="jabber:client" from="firehoser.superfeedr.com" to="julien@superfeedr.com">
#   <event xmlns="http://jabber.org/protocol/pubsub#event">
#     <status xmlns="http://superfeedr.com/xmpp-pubsub-ext" feed="http://pubsubhubbub-example-app.appspot.com/feed">
#       <http code="200">25002 bytes fetched in 0.73s for 1 new entries.</http>
#       <next_fetch>2010-03-25T17:06:30+00:00</next_fetch>
#       <title>PubSubHubBub example app</title>
#     </status>
#     <items node="http://pubsubhubbub-example-app.appspot.com/feed">
#       <item xmlns="http://jabber.org/protocol/pubsub" chunks="1" chunk="1">
#         <entry xmlns="http://www.w3.org/2005/Atom" xml:lang="" xmlns:xml="http://www.w3.org/XML/1998/namespace">
#           <title>cool</title>
#           <content type="text">cool</content>
#           <id>tag:pubhubsubbub-example-app,2009:ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw</id>
#           <published>2010-03-25T16:57:18Z</published>
#           <link type="text/html" href="http://pubsubhubbub-example-app.appspot.com/ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw" title="" rel="alternate"/>
#         </entry>
#         <entry xmlns="http://www.w3.org/2005/Atom" xml:lang="" xmlns:xml="http://www.w3.org/XML/1998/namespace">
#           <title>great</title>
#           <content type="text">great</content>
#           <id>tag:pubhubsubbub-example-app,2009:ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAx</id>
#           <published>2010-03-25T16:57:19Z</published>
#           <link type="text/html" href="http://pubsubhubbub-example-app.appspot.com/ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAx" title="" rel="alternate"/>
#         </entry>
#       </item>
#     </items>
#   </event>
# </message>

class NotificationStanza < Skates::Base::Stanza 

  XMLNS = {
    "ps" => "http://jabber.org/protocol/pubsub#event",
    "ps2" => "http://jabber.org/protocol/pubsub",
    "sf" => "http://superfeedr.com/xmpp-pubsub-ext" } unless defined? XMLNS
  
  def next_fetch
    if !@next_fetch
      time = @node.at_xpath("./ps:event/sf:status/sf:next_fetch", XMLNS).text
      @next_fetch = Time.parse(time)
    end
    @next_fetch
  end
  
  def http_status
    @http_status ||= @node.at_xpath("./ps:event/sf:status/sf:http/@code", XMLNS).text.to_i
  end
  
  def feed_url
    @feed_url ||= @node.at_xpath("./ps:event/sf:status/@feed", XMLNS).text
  end
  
  def message_status
    @message_status ||= @node.at_xpath("./ps:event/sf:status/sf:http", XMLNS).text
  end

  def title
    @title ||= @node.at_xpath("./ps:event/sf:status/sf:title", XMLNS).text
  end
  
  def entries
    if !@entries
      @entries = []
      @node.xpath("./ps:event/ps:items/ps2:item", XMLNS).each do |node|
        @entries.push(Item.new(node))
      end
    end
    @entries
  end
  
end

