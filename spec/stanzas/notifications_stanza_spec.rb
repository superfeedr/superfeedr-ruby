require File.dirname(__FILE__) + '/../spec_helper'
describe NotificationStanza do
  
  before(:each) do
    xml = <<-EOXML
    <message xmlns="jabber:client" from="firehoser.superfeedr.com" to="julien@superfeedr.com">
      <event xmlns="http://jabber.org/protocol/pubsub#event">
        <status xmlns="http://superfeedr.com/xmpp-pubsub-ext" feed="http://pubsubhubbub-example-app.appspot.com/feed">
          <http code="200">25002 bytes fetched in 0.73s for 1 new entries.</http>
          <next_fetch>2010-03-25T17:06:30+00:00</next_fetch>
          <title>PubSubHubBub example app</title>
        </status>
        <items node="http://pubsubhubbub-example-app.appspot.com/feed">
          <item xmlns="http://jabber.org/protocol/pubsub" chunks="2" chunk="1">
            <entry xmlns="http://www.w3.org/2005/Atom" xml:lang="" xmlns:xml="http://www.w3.org/XML/1998/namespace">
              <id>tag:pubhubsubbub-example-app,2009:ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw</id>
              <title>cool</title>
              <content type="text">cool</content>
              <summary>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</summary>
              <published>2010-03-25T16:57:18Z</published>
              <link type="text/html" href="http://pubsubhubbub-example-app.appspot.com/ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw" title="cool" rel="alternate"/>
              <link href="http://domain.tld/entries/12345/comments.xml" rel="replies" type="application/atom+xml" /> 
              <point xmlns="http://www.georss.org/georss">47.597553 -122.15925</point>
              <author>
                <name>John Doe</name>
                <email>john@superfeedr.com</email>
              </author>
              <category term="tag" scheme="http://www.sixapart.com/ns/types#tag" />
              <category term="category" scheme="http://www.sixapart.com/ns/types#tag" />
            </entry>
          </item>
          <item xmlns="http://jabber.org/protocol/pubsub" chunks="2" chunk="2">
            <entry xmlns="http://www.w3.org/2005/Atom" xml:lang="" xmlns:xml="http://www.w3.org/XML/1998/namespace">
              <title>great</title>
              <content type="text">great</content>
              <id>tag:pubhubsubbub-example-app,2009:ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAx</id>
              <published>2010-03-25T16:57:19Z</published>
              <link type="text/html" href="http://pubsubhubbub-example-app.appspot.com/ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAx" title="" rel="alternate"/>
            </entry>
          </item>
        </items>
      </event>
    </message>
    EOXML
    @stanza = NotificationStanza.new(Nokogiri::XML(xml).root)
  end
  
  it "should have the right feed_url" do
    @stanza.feed_url.should == "http://pubsubhubbub-example-app.appspot.com/feed"
  end
  
  it "should have the right message_status" do
    @stanza.message_status.should == "25002 bytes fetched in 0.73s for 1 new entries."
  end
  
  it "should have the right http_status" do
    @stanza.http_status.should == 200
  end
  
  it "should have the right next_fetch" do
    @stanza.next_fetch.should == Time.parse("2010-03-25T17:06:30+00:00")
  end

  it "should have the title" do
    @stanza.title.should == 'PubSubHubBub example app'
  end
  
  it "should have the right number of items" do
    @stanza.entries.count.should == 2
  end
  
  describe "items" do
    before(:each) do
      @item = @stanza.entries.first
    end
    
    it "should have the right chunk" do
      @item.chunk.should == 1
    end
    
    it "should have the right chunks" do
      @item.chunks.should == 2
    end
    
    it "should have the right title" do
      @item.title.should == "cool"
    end
    
    it "should have the right summary" do
      @item.summary.should == "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
    end
    
    it "should have the right unique_id" do
      @item.unique_id.should == "tag:pubhubsubbub-example-app,2009:ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw"
    end
    
    it "should have the right published" do
      @item.published.should == Time.parse("2010-03-25T16:57:18Z")
    end

    it "should have the right number of links" do
      @item.should have(2).links
    end
    
    describe "links" do
      before(:each) do
        @link = @item.links.first
      end
      
      it "should have the right title" do
        @link.title.should == "cool"
      end

      it "should have the right href" do
        @link.href.should == "http://pubsubhubbub-example-app.appspot.com/ahhwdWJzdWJodWJidWItZXhhbXBsZS1hcHByDQsSBUVudHJ5GMGOEAw"
      end

      it "should have the right rel" do
        @link.rel.should == "alternate"
      end

      it "should have the right mime type" do
        @link.type.should == "text/html"
      end
      
    end

    it "should have the right number of locations" do
      @item.should have(1).locations
    end
    
    describe "locations" do
      before(:each) do
        @location = @item.locations.first
      end
      
      it "should have the right lat" do
        @location.lat.should == 47.597553
      end
      
      it "should have the right lon" do
        @location.lon.should == -122.15925
      end
      
    end
    
    it "should have the right number of authors" do
      @item.should have(1).authors
    end

    describe "authors" do
      before(:each) do
        @author = @item.authors.first
      end
      
      it "should have the right name" do
        @author.name.should == "John Doe"
      end
      
      it "should have the right uri" do
        @author.uri.should == nil
      end
      
      it "should have the right email" do
        @author.email.should == "john@superfeedr.com"
      end
      
    end

    it "should have the right number of categories" do
      @item.should have(2).categories
    end
    
    describe "categories" do
      before(:each) do
        @category = @item.categories.first
      end
      
      it "should have the right term" do
        @category.term.should == "tag"
      end
    end
  end
end
