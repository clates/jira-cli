# jira-cli
A command line interface that allows for automation of repetitive JIRA tasks.

# Installation Instructions
1) Clone repo
2) gem install bundler
3) bundle install
4) ruby main.rb

# Usage Notes
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