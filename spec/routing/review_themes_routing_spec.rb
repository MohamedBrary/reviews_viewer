require "rails_helper"

RSpec.describe ReviewThemesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/review_themes").to route_to("review_themes#index")
    end

    it "routes to #new" do
      expect(get: "/review_themes/new").to route_to("review_themes#new")
    end

    it "routes to #show" do
      expect(get: "/review_themes/1").to route_to("review_themes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/review_themes/1/edit").to route_to("review_themes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/review_themes").to route_to("review_themes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/review_themes/1").to route_to("review_themes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/review_themes/1").to route_to("review_themes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/review_themes/1").to route_to("review_themes#destroy", id: "1")
    end
  end
end
