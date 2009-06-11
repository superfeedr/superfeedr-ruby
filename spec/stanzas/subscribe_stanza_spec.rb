require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/iq_query_stanza_spec'
describe SubscribeQueryStanza do
  
  it_should_behave_like "Iq Query Stanzas"
  
  before(:each) do
    @params = { :type => "set", :from => "me@server.com/resource", :nodes => ["http//domain.tld/feed.xml"], :type => "set", :from => "me@server.com/resource"}
  end
  
  it "should have the right node value" do
    SubscribeQueryStanza.new(@params).nodes.should == @params[:nodes]
  end
  
end
