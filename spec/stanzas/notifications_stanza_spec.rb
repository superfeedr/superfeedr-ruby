require File.dirname(__FILE__) + '/../spec_helper'
describe NotificationStanza do
  
  before(:each) do
    xml = <<-EOXML
    <message from='firehoser.superfeedr.com' to='you@superfeedr.com'>
      <event xmlns='http://jabber.org/protocol/pubsub#event'>
        <status feed="http://domain.tld/path/to/feed.xml">
          <http code="200">9718 bytes fetched in 1.462708s : 2 new entries.</http>
          <next_fetch>2009-05-10T11:19:38-07:00</next_fetch>
        </status>
        <items node='http://domain.tld/path/to/feed.xml'>
          <item chunk="1" chunks="2" >
            <entry xmlns='http://www.w3.org/2005/Atom'>
              <title>Soliloquy</title>
              <summary>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</summary>
              <link rel='alternate' type='text/html' href='http://superfeedr.com/entries/12345789'/>
              <id>tag:domain.tld,2009:Soliloquy-32397</id>
              <published>2010-04-05T11:04:21Z</published>
            </entry>
          </item>
          <item chunk="2" chunks="2" >
            <entry xmlns='http://www.w3.org/2005/Atom'>
              <title>Finibus Bonorum et Malorum</title>
              <summary>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.</summary>
              <link rel='alternate' type='text/html' href='http://superfeedr.com/entries/12345788'/>
              <id>tag:domain.tld,2009:Finibus-32398</id>
              <published>2010-04-06T08:54:02Z</published>
            </entry>
          </item>
        </items>
      </event>
    </message>
    EOXML
    @stanza = NotificationStanza.new(xml)
  end
  
  it "should have the right feed_url" do
    @stanza.feed_url.should == "http://domain.tld/path/to/feed.xml"
  end
  
  it "should have the right message_status" 
  
  it "should have the right http_status" do
    @stanza.http_status.should == 200
  end
  
  it "should have the have the right next_fetch" do
    @stanza.next_fetch.should == Time.parse("2009-05-10T11:19:38-07:00")
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
      @item.title.should == "Soliloquy"
    end
    
    it "should have the right summary" do
      @item.summary.should == "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
    end
    
    it "should have the right link" do
      @item.link.should == "http://superfeedr.com/entries/12345789"
    end
    
    it "should have the right unique_id" do
      @item.unique_id.should == "tag:domain.tld,2009:Soliloquy-32397"
    end
    
    it "should have the right published" do
      @item.published.should == Time.parse("2010-04-05T11:04:21Z")
    end
    
  end
  
end