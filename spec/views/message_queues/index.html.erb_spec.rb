require 'spec_helper'

describe "message_queues/index" do
  before(:each) do
    assign(:message_queues, [
      stub_model(MessageQueue,
        :name => "",
        :last_heartbeat => "",
        :last_ingest => "",
        :last_modify => "",
        :last_purge => "",
        :last_pid_ingested => "",
        :last_pid_purged => "",
        :last_pid_modified => ""
      ),
      stub_model(MessageQueue,
        :name => "",
        :last_heartbeat => "",
        :last_ingest => "",
        :last_modify => "",
        :last_purge => "",
        :last_pid_ingested => "",
        :last_pid_purged => "",
        :last_pid_modified => ""
      )
    ])
  end

  it "renders a list of message_queues" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
