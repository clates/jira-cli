require_relative 'login'
require_relative 'config'

def createSubtask(issueName, taskName, hours)

  if (!hasSubTask(issueName, taskName))
      if (hours == 0)
         print "How many hours for \""+ taskName +"\": "
         hours = STDIN.gets.chomp.to_i
         puts hours
      end
      if (hours > 0)
          puts "Creating " + taskName + ' ' + hours.to_s + 'h.'
          parentId = getTaskInfo(issueName)['id']
          projectKey = issueName.split(/-/)[0]
          url = get_domain+'/rest/api/2/issue'
          response = RestClient.post(url, {
            "fields" => {

                       "parent" => {"id" => parentId},
                       "project" => { "key" => projectKey},
                       "summary" => taskName,
                       "labels"=>["Remediation_backlog"],
                       "issuetype" => {
                                     "name" => "Sub-task"
                                  },
                       "timetracking"=>
                       {
                            "originalEstimate" => hours.to_s + "h"
                       },
                       "description" => ""
                   }


          }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)
          return JSON.parse(response)
      end
  else
    puts issueName + " already contains sub task: " + taskName
    return nil
  end
end

def getProjectList()
    url = get_domain+'/rest/api/2/project'
    response = JSON.parse(RestClient.get(url, {:accept => "application/json", :cookie => cookie}))
    return response
end

def getTaskInfo(issueName)
    url = get_domain+'/rest/api/2/issue/' + issueName
    response = JSON.parse(RestClient.get(url, {:accept => "application/json", :cookie => cookie}))
    return response
end

def hasSubTask(issueName, taskName)
    response = getTaskInfo(issueName)
    response["fields"]["subtasks"].each_with_index do | value, idx |
        if (value["fields"]["summary"] == taskName)
         return true
        end
    end
    return false
end

def listSubTasks(issueName)
    response = getTaskInfo(issueName)
    response["fields"]["subtasks"].each_with_index do | value, idx |
        puts (value["fields"]["summary"])
    end
end

def removeCloneTestFromSummary (issueName)
    response = getTaskInfo(issueName)
    summary = response["fields"]["summary"]
    ssplit = summary.split("CLONE - ")
    if (ssplit.size() > 1)
        puts "Updating " + summary + " to " + ssplit[ssplit.size()-1]
        setIssueSummary(issueName, ssplit[ssplit.size()-1])
    end
end

def setIssueSummary (issueName, newtitle)
    url = get_domain+'/rest/api/2/issue/' + issueName
    response = RestClient.put(url, {
        "fields" => {
                   "summary" => newtitle
               }
      }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)
end

def assignToMe(issueName)
  puts "Assigning Task: " + issueName + " to " + get_user 
    url = get_domain+'/rest/api/2/issue/' + issueName
        response = RestClient.put(url, {
            "fields" => {
                       "assignee"=>{
                        "name" => get_user
                      }
                   }
          }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)

end

def assignTo(issueName, userid)
  puts "Assigning Task: " + issueName + " to " + userid 
    url = get_domain+'/rest/api/2/issue/' + issueName
        response = RestClient.put(url, {
            "fields" => {
                       "assignee"=>{
                        "name" => userid
                      }
                   }
          }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)

end

def addLabel(issueName)
    puts "Adding Remediation_backlog label to " + issueName
    url = get_domain+'/rest/api/2/issue/' + issueName
        response = RestClient.put(url, {
            "fields" => {
                       "labels"=>["Remediation_backlog"]
                   }
          }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)

end

def getOpenAssignedTasks
  filter = 'issuetype = Sub-task AND status in (Open, "In Progress", Reopened) AND assignee in (currentUser())'
  url = get_domain + "/rest/api/2/search?jql=" + filter
  response = RestClient.get(url, :content_type => :json,:accept => :json, :cookie => cookie)
  return JSON.parse(response)
end

def logTimeForTask(issueName, seconds)
  url = get_domain+'/rest/api/2/issue/' + issueName + "/worklog"
  puts url
    response = RestClient.post(url, {
        "timeSpentSeconds": seconds
      }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)
  
end

def getSprintStories(sprint)

  filter = 'issuetype != Sub-task AND issuetype != Impediment AND Sprint = ' + sprint.to_s
  url = get_domain + "/rest/api/2/search?jql=" + filter
  response = RestClient.get(url, :content_type => :json,:accept => :json, :cookie => cookie)
  return JSON.parse(response)
end

