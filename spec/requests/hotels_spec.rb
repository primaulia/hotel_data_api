require 'rails_helper'

RSpec.describe "Hotels", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/hotels/index"
      expect(response).to have_http_status(:success)
    end
  end

end
