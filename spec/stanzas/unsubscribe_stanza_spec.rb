require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/iq_query_stanza_spec'
describe UnsubscribeQueryStanza do
  
  it_should_behave_like "Iq Query Stanzas"
  
  before(:each) do
    @params = { :type => "set", :from => "me@server.com/resource", :nodes => ["http//domain.tld/feed.xml", "http//domain.tld/feed2.xml"], :type => "set", :from => "me@server.com/resource"}
  end
  
  it "should have the right node value" do
    UnsubscribeQueryStanza.new(@params).nodes.should == @params[:nodes]
  end
  
end
