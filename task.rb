require_relative 'login'
require_relative 'config'

def createSubtask(issueName, taskName, hours, description='')

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
                       # "labels"=>["Remediation_backlog"],
                       "issuetype" => {
                                     "name" => "Sub-task"
                                  },
                       "timetracking"=>
                       {
                            "originalEstimate" => hours.to_s + "h"
                       },
                       "description" => description,
                       # "assignee" => curuser
                   }
          }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)
          resp = JSON.parse(response)
          assignTo(resp["key"], promptForTeamMember)
          return resp
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
    url = "#{get_domain}/rest/api/2/issue/#{issueName}?fields=reporter,subtasks,summary,description,timetracking,
                                                        issuetype,parent,project,assignee,id,key,customfield_10111"
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
  if userid != 'unassigned'
    puts "Assigning Task: #{issueName} to #{userid}"
    url = get_domain+'/rest/api/2/issue/' + issueName
        response = RestClient.put(url, {
            "fields" => {
                       "assignee"=>{
                        "name" => userid
                      }
                   }
          }.to_json, :content_type => :json,:accept => :json, :cookie => cookie)
  else
    puts "Leaving Task: #{issueName} #{userid}"
  end
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

def getSprintIDByStory(issueName)
  customStr = getTaskInfo(issueName)["fields"]["customfield_10111"].to_s
  customStr = customStr[customStr.index("id="), 7].to_s #magic number because I cbf to do it correctly right now
  puts customStr
  return customStr
end

def getSprintStories(sprint)
  filter = 'issuetype != Sub-task AND issuetype != Impediment AND Sprint = ' + sprint.to_s
  url = get_domain + "/rest/api/2/search?jql=" + filter
  response = RestClient.get(url, :content_type => :json,:accept => :json, :cookie => cookie)
  return JSON.parse(response)
end

