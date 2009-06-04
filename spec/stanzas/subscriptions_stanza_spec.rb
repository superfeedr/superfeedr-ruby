require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/iq_query_stanza_spec'
describe SubscriptionsQueryStanza do
  
  it_should_behave_like "Iq Query Stanzas"
  
  before(:each) do
    @params = { :type => "set", :from => "me@server.com/resource", :page => 3, :type => "set", :from => "me@server.com/resource"}
  end
  
  it "should have the right page value" do
    SubscriptionsQueryStanza.new(@params).page.should == @params[:page].to_s
  end
  
end
