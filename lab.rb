require 'typhoeus'
require 'pry'
require 'json'
require 'ox'
require 'csv'

def parse_response(response, type)
  if type == "Application/json"
    return JSON.parse(response)
  elsif type == "Application/xml"
    return Ox.load(response, mode: :hash)[:device].inject(:merge)
  elsif type == "text/csv"
    CSV.parse(response, headers: :first_row).map(&:to_h)
  end
end


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

responses.flatten.each do |response|
  unless response == nil
    response.keys.each do |key|
      response[(key.to_sym rescue key) || key] = response.delete(key)
    end
  end
end
