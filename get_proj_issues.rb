require 'JSON'
require "rspec"
require 'rest-client'
require_relative 'config.rb'

def get_proj_issue_hash

    url = get_domain+'/rest/api/latest/search'
    jql ="project = "+ get_proj_key
    response = RestClient.post(url, {
        "jql" => jql,
        "startAt" => 0,
        "maxResults" => -1}.to_json, :content_type => :json, :accept => :json, :cookie => cookie)
    init_hash = JSON.parse(response)
    size = init_hash['total']
    puts init_hash["issues"]
    return init_hash["issues"], size, cookie
end