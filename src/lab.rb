require './src/helper.rb'

devices = {
  "0" => "Temperature",
  "1" => "Humidity",
  "2" => "Motion",
  "3" => "Alien Presence",
  "4" => "Dark Matter"
}

URL = "https://desolate-ravine-43301.herokuapp.com"

response = Typhoeus.post(URL, body: {})

secret_key = response.headers["Session"]
urls = JSON.parse(response.body)
request_header = { "Session" => secret_key }


hydra = Typhoeus::Hydra.new
requests = urls.map do |url|
  request = Typhoeus::Request.new(
    URL + url["path"],
    method: :get,
    headers: request_header
  )

  hydra.queue(request)
  request
end

hydra.run

responses = requests.map { |request|
  parsed_response = parse_response(request.response.body, request.response.headers["Content-Type"])
}

responses.delete(nil)

responses = keys_to_symbols(responses.flatten)
responses = standartize_keys(responses)
responses = standartize_values(responses)

grouped_responses = responses.group_by { |k| k[:sensor_type] }

grouped_responses.each do |key, value|
  if devices.key?(key)
    puts devices[key] + "\n"
    value.each do |device|
      puts "Device " + device[:device_id] + " - " + device[:value]
    end
    puts "\n"
  end
end
