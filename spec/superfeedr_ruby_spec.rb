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
        Superfeedr.subscribe(@node, &@block)
      }.should raise_error(Superfeedr::NotConnected)
    end
      
    it "should create a new SubscribeQueryStanza with the right url" do
      SubscribeQueryStanza.should_receive(:new).with({:node => @node, :from => @mock_connection.jid}).and_return(@mock_stanza)
      Superfeedr.subscribe(@node, &@block)
    end
    
    it "should add a Proc that just calls the block in params to the @@callbacks" do
      callback = Proc.new {
        
      }
      Proc.should_receive(:new).and_return(callback)
      Superfeedr.subscribe(@node, &@block)
      Superfeedr.callbacks[@mock_stanza.id].should == callback
    end
    
    it "should send the stanza"  do
      Superfeedr.should_receive(:send).with(@mock_stanza).and_return(true)
      Superfeedr.subscribe(@node, &@block)
    end
  end
  
  describe "unsubscribe" do
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
        Superfeedr.unsubscribe(@node, &@block)
      }.should raise_error(Superfeedr::NotConnected)
    end
      
    it "should create a new SubscribeQueryStanza with the right url" do
      UnsubscribeQueryStanza.should_receive(:new).with({:node => @node, :from => @mock_connection.jid}).and_return(@mock_stanza)
      Superfeedr.unsubscribe(@node, &@block)
    end
    
    it "should add a Proc that just calls the block in params to the @@callbacks" do
      callback = Proc.new {
        
      }
      Proc.should_receive(:new).and_return(callback)
      Superfeedr.unsubscribe(@node, &@block)
      Superfeedr.callbacks[@mock_stanza.id].should == callback
    end
    
    it "should send the stanza"  do
      Superfeedr.should_receive(:send).with(@mock_stanza).and_return(true)
      Superfeedr.unsubscribe(@node, &@block)
    end
  end
  
  describe "subscriptions" do
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
        Superfeedr.subscriptions(@page, &@block)
      }.should raise_error(Superfeedr::NotConnected)
    end
      
    it "should create a new SubscribeQueryStanza with the right url" do
      SubscriptionsQueryStanza.should_receive(:new).with({:page => @page, :from => @mock_connection.jid}).and_return(@mock_stanza)
      Superfeedr.subscriptions(@page, &@block)
    end
    
    it "should add a Proc that just calls the block in params to the @@callbacks" do
      callback = Proc.new {
        
      }
      Proc.should_receive(:new).and_return(callback)
      Superfeedr.subscriptions(@page, &@block)
      Superfeedr.callbacks[@mock_stanza.id].should == callback
    end
    
    it "should send the stanza"  do
      Superfeedr.should_receive(:send).with(@mock_stanza).and_return(true)
      Superfeedr.subscriptions(@page, &@block)
    end
  end
  
end
