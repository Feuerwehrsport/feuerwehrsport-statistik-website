def json_body
  JSON.parse(response.body, symbolize_names: true)
end

def expect_json_response
  expect(response.header['Content-Type']).to include 'application/json'
end