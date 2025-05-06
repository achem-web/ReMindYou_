require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'dotenv/load'

post '/generate-motivation' do
  content_type :json

  request_payload = JSON.parse(request.body.read)
  mood = request_payload["mood"]

  prompt = "Give me a short motivational quote and a follow-up message for someone feeling #{mood}."

  api_key = ENV['API_KEY']
  uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{api_key}")

  begin
    request = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })
    request.body = { contents: [{ parts: [{ text: prompt }] }] }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    data = JSON.parse(response.body)

    if data["candidates"] && data["candidates"][0]["content"] && data["candidates"][0]["content"]["parts"]
      ai_text = data["candidates"][0]["content"]["parts"][0]["text"]
      quote, *rest = ai_text.split("\n")
      advice = rest.join(" ")

      { messages: [{ text: quote.strip }, { text: advice.strip }] }.to_json
    else
      status 500
      { error: "Unexpected response format from API" }.to_json
    end
  rescue => e
    status 500
    { error: "Error generating motivation: #{e.message}" }.to_json
  end
end

set :port, 4568
