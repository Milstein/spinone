require 'rails_helper'

describe '/api/v1/status', :type => :api do
  it "get status" do
    get '/api/status'

    response = JSON.parse(last_response.body)
    data = response.fetch('data', {})
    status = data.first
    expect(status['type']).to eq("status")
  end

  it "returns correct content_type" do
    get '/api/status'

    expect(last_response.header["Content-Type"]).to eq("application/json; charset=utf-8")
  end
end
