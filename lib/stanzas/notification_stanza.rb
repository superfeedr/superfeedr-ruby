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
class Item
  include SAXMachine
  element :item, :as => :chunk, :value => :chunk
  element :item, :as => :chunks, :value => :chunks
  element :title
  element :summary
  element :link, :as => :link, :value => :href
  element :id, :as => :unique_id
  element :published
  
  def published
    Time.parse(@published)
  end
  
  def chunks
    @chunks.to_i
  end
  
  def chunk
    @chunk.to_i
  end
  
end


##
# Notification : sent every time a feed has been fetched. It has the following methods: 
# - message_status : a simple message that gives information about the last fetch
# - http_status : status of the http response
# - feed_url : url of the feed
# - next_fetch : Time when the feed will be fetched again (this is purely informative and it might change)
# - items : array of new items detected (might be empty)
class NotificationStanza
  include SAXMachine
  
  def initialize(xml)
    parse(xml.to_s)
  end
  
  def next_fetch
    Time.parse(@next_fetch)
  end
  
  def http_status
    @http_status.to_i
  end
  
  element :http, :as => :message_status
  element :http, :as => :http_status, :value => :code
  element :status, :value => :feed, :as => :feed_url
  element :next_fetch
  elements :item, :as => :entries, :class => Item
  
end

