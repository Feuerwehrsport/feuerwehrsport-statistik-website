def json_body
  JSON.parse(response.body, symbolize_names: true)
end

def expect_json_response(hash=nil)
  expect(response.header['Content-Type']).to include 'application/json'
  expect(json_body).to eq hash if hash
end

def expect_api_response(hash={})
  default_hash = { success: true, login: true }
  expect_json_response(default_hash.merge(hash))
end