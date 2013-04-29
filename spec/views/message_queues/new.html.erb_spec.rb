require 'spec_helper'

describe "message_queues/new" do
  before(:each) do
    assign(:message_queue, stub_model(MessageQueue,
      :name => "",
      :last_heartbeat => "",
      :last_ingest => "",
      :last_modify => "",
      :last_purge => "",
      :last_pid_ingested => "",
      :last_pid_purged => "",
      :last_pid_modified => ""
    ).as_new_record)
  end

  it "renders new message_queue form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => message_queues_path, :method => "post" do
      assert_select "input#message_queue_name", :name => "message_queue[name]"
      assert_select "input#message_queue_last_heartbeat", :name => "message_queue[last_heartbeat]"
      assert_select "input#message_queue_last_ingest", :name => "message_queue[last_ingest]"
      assert_select "input#message_queue_last_modify", :name => "message_queue[last_modify]"
      assert_select "input#message_queue_last_purge", :name => "message_queue[last_purge]"
      assert_select "input#message_queue_last_pid_ingested", :name => "message_queue[last_pid_ingested]"
      assert_select "input#message_queue_last_pid_purged", :name => "message_queue[last_pid_purged]"
      assert_select "input#message_queue_last_pid_modified", :name => "message_queue[last_pid_modified]"
    end
  end
end
