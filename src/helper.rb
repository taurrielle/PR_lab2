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

def keys_to_symbols(responses)
  responses.each do |response|
    response.keys.each do |key|
      response[(key.to_sym rescue key) || key] = response.delete(key)
    end
  end
  responses
end

def standartize_keys(responses)
  responses.each do |response|
    response[:device_id] = response.delete(:id) if response.has_key? :id
    response[:sensor_type] = response.delete(:type) if response.has_key? :type
  end
  responses
end

def standartize_values(responses)
  responses = responses.each do |response|
    response.keys.each {|k| response[k] = response[k].to_s}
  end
  responses
end