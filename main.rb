require_relative 'task'
require_relative 'issue'
require_relative 'config'
require 'json'
require 'pp'
require "highline/import"
require 'io/console'

file = File.read('./tasktypes.json')
@storytypes = JSON.parse(file);

def fillOutSubtasks(issueName, storytype)
    removeCloneTestFromSubtasks(issueName)
    if storytype["customitemprompts"] != nil
        storytype["customitemprompts"].each_with_index do | value, idx |
            puts "Enter a blank title to proceed to the next custom item prompt."
            print value["prompt"]
            devtaskname = STDIN.gets.chomp
            while not devtaskname.empty?
                createSubtask(issueName, devtaskname, 0)
                print value["prompt"]
                devtaskname = STDIN.gets.chomp
            end
        end
    end
    
    storytype["subtasks"].each_with_index do | value, idx | 
        createSubtask(issueName, value["summary"], value["hours"])
    end
end

def createStory(storyname, project)
    newstory = createEmptyStory(storyname, project)
    @storytypes["options"].each_with_index do | value, idx |
      if value["name"] == "Fill Out New Feature"
        fillOutSubtasks(newstory["key"], value)
        return
      end
    end  
end

def createEmptyStory(storyname, project)
  newstory = createIssue(storyname, "Story", project)
    puts ""
    puts newstory["key"]
    return newstory
end

def createNonFunctionalStory(storyname, project)
  newstory = createIssue(storyname, "Non Functional Requirement", project)
    puts ""
    puts newstory["key"]
    return newstory
end

def createBug(storyname, project)
    newstory = createIssue(storyname, "Bug", project)
    puts ""
    puts newstory["key"]

    @storytypes["options"].each_with_index do | value, idx |
      if value["name"] == "Fill Out Bug"
        fillOutSubtasks(newstory["key"], value)
        return
      end
    end  
end

def createImpediment(storyname, project)
    newstory = createIssue(storyname, "Impediment", project)
    puts ""
    puts newstory["key"]
    prompt = "Subtask for #{storyname}"
    print prompt
    devtaskname = STDIN.gets.chomp
    while not devtaskname.empty?
        createSubtask(newstory["key"], devtaskname, 0)
        print prompt
        devtaskname = STDIN.gets.chomp
    end
end

def removeCloneTestFromSubtasks(issueName)
    response = getTaskInfo(issueName)
    response["fields"]["subtasks"].each_with_index do | value, idx | 
        removeCloneTestFromSummary(value["key"])
    end
end

def setLabelsOnSubtasks(issueName)
    response = getTaskInfo(issueName)
    response["fields"]["subtasks"].each_with_index do | value, idx | 
        addLabel(value["key"])
    end
end

def assignTaskToMe(issueName)
    response = getTaskInfo(issueName)
    response["fields"]["subtasks"].each_with_index do | value, idx |       
      parenttask = response
      puts "Assign this task to yourself?"
      puts "------------------------------"
      puts "Story: " +  parenttask["key"] + ": " + parenttask["fields"]["summary"]
      puts " Task: " + value["fields"]["summary"]
      puts "------------------------------"
      assign = STDIN.gets.chomp

      if assign == "y"
        assignToMe(value["key"])
      end
   end    
end


def viewTask(issueName)
    response = getTaskInfo(issueName)
    pp(response)
end

def viewMyTasks
    response = getOpenAssignedTasks
    pp(response)
end

def logTime
    response = getOpenAssignedTasks
    response["issues"].each_with_index do | value, idx |
      parenttask = getTaskInfo(value["fields"]["parent"]["key"])
      puts "How many hours for task?"
      puts "------------------------------"
      puts "Story: " +  parenttask["key"] + ": " + parenttask["fields"]["summary"]
      puts " Task: " + value["fields"]["summary"]
      puts "------------------------------"
      hours = STDIN.gets.chomp

      if hours.to_f > 0.0
        logTimeForTask(value["key"], (hours.to_f) * 60 * 60)
      end
    end
end

def viewCreateTaskMetaData()
    pp(createIssueMetaData())
end

def viewSprintStories()
    response = getSprintStories(presets[:sprint])
    response["issues"].each_with_index do | value, idx |
      puts "Story: " + value["key"] + ": " + value["fields"]["summary"]
    end
end

def promptForTeamMember()
  curuser = 'none'
  choose do |menu|
    menu.prompt = "Assign to?"

    presets[:team_ids].each_with_index do | user, idx |
      menu.choice(user[:name]) { curuser = user[:user_id] }
    end
  end
  return curuser
end

def assignUnassignedSubtasks()
    response = getSprintStories(presets[:sprint])
    response["issues"].each_with_index do | parenttask, idx |
      parenttask["fields"]["subtasks"].each_with_index do | value, idx |
        subtask = getTaskInfo(value["key"])
        assignee = subtask["fields"]["assignee"]
        if assignee == nil
          puts "------------------------------"
          puts "Story: " +  parenttask["key"] + ": " + parenttask["fields"]["summary"]
          puts " Task: " + subtask["fields"]["summary"]
          puts "------------------------------"
          assignTo(value["key"], promptForTeamMember)
        end
      end
    end
end

def getTeamCapacity()
    response = getSprintStories(presets[:sprint])
    sumHours = Hash.new
    response["issues"].each_with_index do | parenttask, idx |
      begin
      parenttask["fields"]["subtasks"].each_with_index do | value, idx |
        subtask = getTaskInfo(value["key"])
        sumHours[subtask["fields"]["assignee"]["key"]] = 0 if sumHours[subtask["fields"]["assignee"]["key"]] == nil
        sumHours[subtask["fields"]["assignee"]["key"]] += (subtask["fields"]["timetracking"]["remainingEstimateSeconds"].to_i / 3600)
        print "."
      end
      rescue
        #Figure out how to gracefully catch a failure.
      end
    end
    puts ""
    puts "-----------Team Capacity Summary-------------------"
    presets[:team_ids].each do |userid|
      assignedHours = sumHours[userid[:user_id]] == nil ? 0 : sumHours[userid[:user_id]].to_f
      puts "User: #{userid[:user_id]}:"
      puts "   Assigned Hours: \t#{assignedHours}"
      puts "   Available Hours:\t#{userid[:capacity]}"
      puts "   Capacity: \t\t#{(assignedHours*100 /  userid[:capacity]).round(2)}%"
    end
    puts "---------------------------------------------------"

end

begin
  puts
  loop do
    choose do |menu|
      menu.prompt = "What action on next?"
      @storytypes["options"].each_with_index do | value, idx |
        menu.choice(value["name"]) { fillOutSubtasks(promptForIssue, value) }
      end      
      menu.choice("Remove Clone From Subtasks") { removeCloneTestFromSubtasks(promptForIssue) }
      menu.choice("Set Labels on Subtasks") { setLabelsOnSubtasks(promptForIssue) }
      menu.choice("View Issue") {viewTask(promptForIssue) }
      menu.choice("View Assigned Tasks") { viewMyTasks() }
      menu.choice("Log Hours") { logTime() }      
      menu.choice("Create Story") {createStory(promptForIssueTitle, promptForProject)}
      menu.choice("Create Empty Story") {createEmptyStory(promptForIssueTitle, promptForProject)}
      menu.choice("Create Bug") {createBug(promptForIssueTitle, promptForProject)}
      menu.choice("Create Non-Functional Story") {createNonFunctionalStory(promptForIssueTitle, promptForProject)}
      menu.choice("Create Impediment") {createImpediment(promptForIssueTitle, promptForProject)}      
      menu.choice("Assign Task To Me") { assignTaskToMe(promptForIssue) }
      menu.choice("View Create Task Metadata") {viewCreateTaskMetaData()}
      menu.choice("View Sprint Stories") {viewSprintStories()}
      menu.choice("Assign Unassigned Subtasks") {assignUnassignedSubtasks()}
      menu.choice("Get Team Capacity") {getTeamCapacity()}
      menu.choice("Get Sprint ID By Story") {getSprintIDByStory(promptForIssue)}
      menu.choice(:Quit, "Exit program.") { exit }
    end
  end
end