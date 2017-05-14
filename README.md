# jira-cli
A command line interface that allows for automation of repetitive JIRA tasks.

# Installation Instructions
1. Clone repo
2. gem install bundler
3. bundle install
4. ruby main.rb

#Typical Sprint Planning Usage
1. Assign some story to the sprint through actual JIRA, then run the Get Sprint ID by Story to get the sprint ID.
2. Fill out the Sprint ID found in presets.rb
3. Fill out the users and their available hours in presets.rb
     {
         :name => "Chris (dev)", #Name as it will show up in the command prompt. No relationship to JIRA.
         :user_id => "vohuua", #This must match the user's "ID" in JIRA. This is what they log in with, and what you @ them with.
         :capacity => 50 # This is used to get everyone's capacity in on of the menu options.
     },
4. Bring in a story and task it out using 1-6.
5. After the story is added to the sprint, check the team capacity and plan the next story with that in mind.
6. Repeat step 3-5.

# Generic Usage Notes
1-6. Fill Out *
    Looks through the tasktypes.json for "name":*
    Iterates the custom prompts setting items as posted. These could be {TODO: List custom prompts}
    Iterates the subtasks generating all tasks that have an hour set in the template. Tasks without hour set (0)
    are prompted for the hours estimated.

7. Remove Clone From Subtasks
8. Set Labels on Subtasks
9. View Issue
    Prompts for the issue number and will list the json returned from a given issue.

10. View Assigned Tasks

11. Log Hours
    Prompts for a given story and then prompts for hours.

12-16. Create *
    Looks through the tasktypes.json for "name":*
    Iterates the custom prompts setting items as posted. These could be {TODO: List custom prompts}
    Iterates the subtasks generating all tasks that have an hour set in the template. Tasks without hour set (0)
    are prompted for the hours estimated.

17. Assign Task To Me
    Prompts for a task then assigns the task to the current token'd user.
18. View Create Task Metadata
19. View Sprint Stories
    Shows the stories associated with the sprintID found in presets.rb

20. Assign Unassigned Subtasks
    Assign tasks to users that are defined in the presets.rb. You will need the sprint ID these are in. To find
    this value, go to the remediation board and find it in the URL.

21. Quit
    Exit the program.



#Example TaskType

This tasktype will prompt the user for dev tasks first (which are usually unique to the story), and then
follow up and generate a series of subtasks to fill out the team's definition of done.

Remember!    "hours": 0 means that the user will be prompted for the hours.

{
    "name": "Fill Out New Feature",
    "customitemprompts": [
        {
            "prompt": "Development Task Name:"
        }
    ],
    "subtasks": [
        {
            "summary": "Unit Test",
            "hours": 0
        },
        {
            "summary": "Code Review",
            "hours": 0
        },
        {
            "summary": "QA- Create/Update Manual Test",
            "hours": 4
        },
        {
            "summary": "QA-Code Review Manual Test Script",
            "hours": 1
        },
        {
            "summary": "QA- iPhone/Safari/VO - 508 Manual Testing",
            "hours": 3
        },
        {
            "summary": "QA-Android/Chrome/Talkback - 508 Manual Testing",
            "hours": 3
        },
        {
            "summary": "QA-Windows/IE/NVDA - 508 Manual Testing",
            "hours": 3
        },
        {
            "summary": "QA-Create/Edit Automated Test Cases",
            "hours": 6
        },
        {
            "summary": "QA-Execute Automated Test In Branch",
            "hours": 2
        },
        {
            "summary": "QA-Automated Test Case Review",
            "hours": 2
        },
        {
            "summary": "Create / Update Smoke Test",
            "hours": 3
        },
        {
            "summary": "Merge to afs-telehealth",
            "hours": 0
        },
        {
            "summary": "QA-Automated Test Execution In afs-telehealth",
            "hours": 2
        },
        {
            "summary": "Smoke Test in afs-telehealth",
            "hours": 1
        }
    ]
}


Even something as simple as

{
    "name": "Fill Out Custom",
    "customitemprompts": [
        {
            "prompt": "Custom Task Name:"
        }
    ],
    "subtasks": []
}

Allows you to enter tasks much faster than through the JIRA interface.