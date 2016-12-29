require_relative 'login'
require_relative 'config'

def createIssue(issueTitle, issueType, projectKey)
    puts "Creating " + issueTitle          
    url = get_domain+'/rest/api/2/issue'
    response = RestClient.post(url, {
      "fields" => {                       
                 "project" => { "key" => projectKey},
                 "summary" => issueTitle,
                 "labels"=>["Remediation_backlog"],
                 "issuetype" => {
                               "name" => issueType
                            },                       
                 "description" => ""
             }


    }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)
    return JSON.parse(response)        
end

def createIssueMetaData()
    url = get_domain+'/rest/api/2/issue/createmeta'
    response = RestClient.get(url, :accept => :json, :cookie => cookie)
    return JSON.parse(response)
end

