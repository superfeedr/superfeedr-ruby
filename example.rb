require "rubygems"
require "superfeedr"

## You can have all the XMPP logging by changing the Babylon log level
Babylon.logger.level = Log4r::DEBUG


##
# Don't ever forget that all this is ASYNCHRONOUS... 
# If you don't run EM in your program, then it will started for... however, EM.run begin a blocking call, you shoudl probably run it into a specific Thread to keep the rest of your app running  :)
Superfeedr.connect("demo@superfeedr.com", "superfeedr") do
  puts "Yay... connected ;)" 
    
  Superfeedr.on_notification do |notification|
    puts "The feed #{notification.feed_url} has been fetched (#{notification.http_status}: #{notification.message_status}) and will be fecthed again in #{(notification.next_fetch - Time.now)/60} minutes."
    notification.entries.each do |e|
      puts " - #{e.title} (#{e.link}) was published (#{e.published}) with #{e.unique_id} as unique id : \n #{e.summary} (#{e.chunk}/#{e.chunks})"
    end
  end
    
  Superfeedr.subscribe("http://github.com/superfeedr.atom") do 
    puts "Yay, subscribed to the github Atom feed for Superfeedr" 
    Superfeedr.unsubscribe("http://github.com/superfeedr.atom") do 
      puts "Sad, you unsubscribed from the github Atom feed for Superfeedr" 
    end   
  end
  
  Superfeedr.subscribe("http://feeds.feedburner.com/NotifixiousFoundersBlog") do 
    puts "Subscribed to Notifixious' blog"
  end
end
