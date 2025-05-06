require 'sinatra'
require 'json'
require 'net/http'
require 'uri'

post '/generate-motivation' do
  content_type :json
  request_payload = JSON.parse(request.body.read)
  mood = request_payload["mood"]

  prompt = "Give me a short motivational quote and a follow-up message for someone feeling #{mood}."

  api_key = 'AIzaSyBjptcdGVz9N0Ijtudh9QnWVp0XzyWHUug'
  uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{api_key}")

  begin
    response = Net::HTTP.post(
      uri,
      { contents: [{ parts: [{ text: prompt }] }] }.to_json,
      { "Content-Type" => "application/json" }
    )

    data = JSON.parse(response.body)
    ai_text = data["candidates"][0]["content"]["parts"][0]["text"]
    quote, *rest = ai_text.split("\n")
    advice = rest.join(" ")

    { messages: [{ text: quote.strip }, { text: advice.strip }] }.to_json
  rescue => e
    status 500
    { error: "Error generating motivation: #{e.message}" }.to_json
  end
end
