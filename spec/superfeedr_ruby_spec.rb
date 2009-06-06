require File.dirname(__FILE__) + '/spec_helper'

describe Superfeedr do
  
  before(:each) do
    @mock_connection = mock(Babylon::XmppConnection, {:send_xml => true, :jid => "client@server.tld/resource"})
  end
  
  describe "connect" do
  end
  
  describe "on_stanza" do
  end
  
  
  describe "subscribe" do
    it "should call add_feed with feeds supplied" do
      feeds = "a", "b", "c", "d"
      feeds.each do |feed|
        Superfeedr.should_receive(:add_feed).with(feed).and_yield(true)
      end
      Superfeedr.subscribe(feeds) do |result|
        result.should be_true
      end
    end
  end
  
  describe "unsubscribe" do
    it "should call remove_feed with feeds supplied" do
      feeds = "a", "b", "c", "d"
      feeds.each do |feed|
        Superfeedr.should_receive(:remove_feed).with(feed).and_yield(true)
      end
      Superfeedr.unsubscribe(feeds) do |result|
        result.should be_true
      end
    end
  end
  
  describe "subscriptions" do
    it "should call subscriptions_by_page for each page as long as they're not empty" do
      def method_called_upon_page
      end
      self.should_receive(:method_called_upon_page).exactly(4).times
      3.times do |t|
        Superfeedr.should_receive(:subscriptions_by_page).with(t+1).and_yield(["a", "b", "c"])
      end
      Superfeedr.should_receive(:subscriptions_by_page).with(4).and_yield([])      
      Superfeedr.subscriptions do |result|
        method_called_upon_page
      end
    end
  end
  
  
  describe "add_feed" do
    before(:each) do
      Superfeedr.stub!(:connection).and_return(@mock_connection)
      Superfeedr.stub!(:send).and_return(true)
      @block = Proc.new {
        
      }
      @node = "http://domain.com/feed.xml"
      @mock_stanza = mock(SubscribeQueryStanza, {:id => "123"})
      SubscribeQueryStanza.stub!(:new).and_return(@mock_stanza)
    end
    
    it "should raise an error if not connected" do
      Superfeedr.should_receive(:connection).and_return(nil)
      lambda {
        Superfeedr.add_feed(@node, &@block)
      }.should raise_error(Superfeedr::NotConnected)
    end
      
    it "should create a new SubscribeQueryStanza with the right url" do
      SubscribeQueryStanza.should_receive(:new).with({:node => @node, :from => @mock_connection.jid}).and_return(@mock_stanza)
      Superfeedr.add_feed(@node, &@block)
    end
    
    it "should add a Proc that just calls the block in params to the @@callbacks" do
      Superfeedr.add_feed(@node, &@block)
      Superfeedr.callbacks[@mock_stanza.id][:method].should == Superfeedr.method(:on_subscribe)
      Superfeedr.callbacks[@mock_stanza.id][:param].should == @block
    end
    
    it "should send the stanza"  do
      Superfeedr.should_receive(:send).with(@mock_stanza).and_return(true)
      Superfeedr.add_feed(@node, &@block)
    end
  end
  
  describe "remove_feed" do
    before(:each) do
      Superfeedr.stub!(:connection).and_return(@mock_connection)
      Superfeedr.stub!(:send).and_return(true)
      @block = Proc.new {
        
      }
      @node = "http://domain.com/feed.xml"
      @mock_stanza = mock(UnsubscribeQueryStanza, {:id => "123"})
      UnsubscribeQueryStanza.stub!(:new).and_return(@mock_stanza)
    end
    
    it "should raise an error if not connected" do
      Superfeedr.should_receive(:connection).and_return(nil)
      lambda {
        Superfeedr.remove_feed(@node, &@block)
      }.should raise_error(Superfeedr::NotConnected)
    end
      
    it "should create a new SubscribeQueryStanza with the right url" do
      UnsubscribeQueryStanza.should_receive(:new).with({:node => @node, :from => @mock_connection.jid}).and_return(@mock_stanza)
      Superfeedr.remove_feed(@node, &@block)
    end
    
    it "should add a Proc that just calls the block in params to the @@callbacks" do
      Superfeedr.remove_feed(@node, &@block)
      Superfeedr.callbacks[@mock_stanza.id][:method].should == Superfeedr.method(:on_unsubscribe)
      Superfeedr.callbacks[@mock_stanza.id][:param].should == @block
    end
    
    it "should send the stanza"  do
      Superfeedr.should_receive(:send).with(@mock_stanza).and_return(true)
      Superfeedr.remove_feed(@node, &@block)
    end
  end
  
  describe "subscriptions_by_page" do
    before(:each) do
      Superfeedr.stub!(:connection).and_return(@mock_connection)
      Superfeedr.stub!(:send).and_return(true)
      @block = Proc.new {
        
      }
      @page = 3
      @mock_stanza = mock(SubscriptionsQueryStanza, {:id => "123"})
      SubscriptionsQueryStanza.stub!(:new).and_return(@mock_stanza)
    end
    
    it "should raise an error if not connected" do
      Superfeedr.should_receive(:connection).and_return(nil)
      lambda {
        Superfeedr.subscriptions_by_page(@page, &@block)
      }.should raise_error(Superfeedr::NotConnected)
    end
      
    it "should create a new SubscribeQueryStanza with the right url" do
      SubscriptionsQueryStanza.should_receive(:new).with({:page => @page, :from => @mock_connection.jid}).and_return(@mock_stanza)
      Superfeedr.subscriptions_by_page(@page, &@block)
    end
    
    it "should add a Proc that just calls the block in params to the @@callbacks" do
      Superfeedr.subscriptions_by_page(@page, &@block)
      Superfeedr.callbacks[@mock_stanza.id][:method].should == Superfeedr.method(:on_subscriptions)
      Superfeedr.callbacks[@mock_stanza.id][:param].should == @block
      
    end
    
    it "should send the stanza"  do
      Superfeedr.should_receive(:send).with(@mock_stanza).and_return(true)
      Superfeedr.subscriptions_by_page(@page, &@block)
    end
  end
  
  describe "on_subscribe" do
    it "should call the block with true if the stanza type is 'result'" do
      xml = <<-EOXML
      <iq type="result" to="you@superfeedr.com/home" from="firehoser.superfeedr.com" id="sub1">
        <pubsub xmlns="http://jabber.org/protocol/pubsub">
          <subscription jid="you@superfeedr.com" subscription="subscribed" node="http://domain.tld/path/to/feed.xml"/>
        </pubsub>
      </iq>
      EOXML
      stanza = Nokogiri::XML(xml) 
      Superfeedr.on_subscribe(stanza.root) do |res|
        res.should be_true
      end
    end
    
    it "should call the block with false if the stanza type is not 'result'" do
      xml = <<-EOXML
      <iq type="error" to="you@superfeedr.com/home" from="firehoser.superfeedr.com" id="sub1">
        <pubsub xmlns="http://jabber.org/protocol/pubsub">
          <subscription jid="you@superfeedr.com" subscription="subscribed" node="http://domain.tld/path/to/feed.xml"/>
        </pubsub>
      </iq>
EOXML
      stanza = Nokogiri::XML(xml) 
      Superfeedr.on_subscribe(stanza.root) do |res|
        res.should be_false
      end
    end
    
  end
  
  describe "on_unsubscribe" do
    it "should call the block with true if the stanza type is 'result'" do
      xml = <<-EOXML
        <iq type='result' from='firehoser.superfeedr.com' to='you@superfeedr.com/home' id='unsub1' />
      EOXML
      stanza = Nokogiri::XML(xml) 
      Superfeedr.on_unsubscribe(stanza.root) do |res|
        res.should be_true
      end
    end
    
    it "should call the block with false if the stanza type is not 'result'" do
      xml = <<-EOXML
        <iq type='error' from='firehoser.superfeedr.com' to='you@superfeedr.com/home' id='unsub1' />
      EOXML
      stanza = Nokogiri::XML(xml) 
      Superfeedr.on_unsubscribe(stanza.root) do |res|
        res.should be_false
      end
    end
  end
  
  describe "on_subscriptions" do
    it "should call the block with the page number and the list of feeds as an array" do
      xml = <<-EOXML
      <iq type="result" to="you@superfeedr.com/home" id="subman1" from="firehoser.superfeedr.com">
        <pubsub xmlns="http://jabber.org/protocol/pubsub" xmlns:superfeedr="http://superfeedr.com/xmpp-pubsub-ext" >
          <subscriptions superfeedr:page="3">
            <subscription node="http://domain.tld/path/to/a/feed/atom.xml" subscription="subscribed" jid="you@superfeedr.com" />
            <subscription node="http://domain2.tld/path/to/feed.rss" subscription="subscribed" jid="you@superfeedr.com" />
          </subscriptions>
        </pubsub>
      </iq>
      EOXML
      stanza = Nokogiri::XML(xml) 
      Superfeedr.on_subscriptions(stanza.root) do |page, subscriptions|
        page.should == 3
        subscriptions.should == ["http://domain.tld/path/to/a/feed/atom.xml", "http://domain2.tld/path/to/feed.rss"] 
      end
    end
    
  end
  
end
