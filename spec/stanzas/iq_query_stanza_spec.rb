require File.dirname(__FILE__) + '/../spec_helper'

shared_examples_for "Iq Query Stanzas" do

  it "should have the right type" do
    IqQueryStanza.new(@params).type.should == @params[:type]
  end
    
  it "should have the right to" do
    IqQueryStanza.new(@params).to.should == "firehoser.superfeedr.com"
  end
  
  it "should have a random id" do
    IqQueryStanza.new(@params).id.should match /[0..9]*/
  end
  
  it "should have the right from" do
    IqQueryStanza.new(@params).from.should == @params[:from]
  end

end

describe IqQueryStanza do
  before(:each) do
    @params = { :type => "set", :from => "me@server.com/resource"}
  end
  
  it_should_behave_like "Iq Query Stanzas"
  
end