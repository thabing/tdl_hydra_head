require 'spec_helper'

describe "MessageQueues" do
  describe "GET /message_queues" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get message_queues_path
      response.status.should be(200)
    end
  end
end
