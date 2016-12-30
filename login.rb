require 'json'
require 'rest-client'
require_relative 'config.rb'

def login
url = get_domain+'/rest/auth/1/session'
    response = RestClient.post(url, {:username => get_user, :password => get_pw }.to_json, :content_type => :json, :accept => :json)
    json_hash = JSON.parse(response)
    temp = json_hash['session']
    return temp['name']+'=' + temp['value']
end
