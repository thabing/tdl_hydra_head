require "spec_helper"

describe MessageQueuesController do
  describe "routing" do

    it "routes to #index" do
      get("/message_queues").should route_to("message_queues#index")
    end

    it "routes to #new" do
      get("/message_queues/new").should route_to("message_queues#new")
    end

    it "routes to #show" do
      get("/message_queues/1").should route_to("message_queues#show", :id => "1")
    end

    it "routes to #edit" do
      get("/message_queues/1/edit").should route_to("message_queues#edit", :id => "1")
    end

    it "routes to #create" do
      post("/message_queues").should route_to("message_queues#create")
    end

    it "routes to #update" do
      put("/message_queues/1").should route_to("message_queues#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/message_queues/1").should route_to("message_queues#destroy", :id => "1")
    end

  end
end
