require 'io/console'
require_relative 'presets'
@username = ""
@pw = ""
@cookie = ""

def presets
  return $presets
end

def get_user
  if @username == "" then
    print "Username: "
    @username = STDIN.gets.chomp
  end
  return @username
end
def get_pw
  if @pw == "" then
      print "Password: "
      @pw = STDIN.noecho(&:gets).chomp
    end
    return @pw
end

def get_host
  return 'issues.mobilehealth.va.gov'
end

def get_domain
  return "https://" + get_host
end

def get_proj_key
   if ARGV[0] == nil then
   throw "Project Key Required"
   end
  return ARGV[0]
end

def get_issue_number
    return ARGV[1]
end

def promptForIssue
      print "Issue: "
        return STDIN.gets.chomp
end

def promptForIssueTitle
      print "Issue Title: "
        return STDIN.gets.chomp
end

def promptForIssueType
      print "Issue Type: "
        return STDIN.gets.chomp
end

def promptForProject
    x = ''
    projList = getProjectList()
    keys= projList.collect{|x|x['key']}
    while x == '' or x.downcase == 'display' or keys.include?(x) == false do
      puts "Enter the Project Key or 'display' to show all available projects and keys."
      print 'Issue Project: '
      x = STDIN.gets.chomp
      if x.downcase == 'display'
        puts projList.collect{|x|"#{x['key']} : #{x['name']}"}
        print 'Issue Project: '
        x = STDIN.gets.chomp
      end
    end

    return x
end

def cookie
     if @cookie == "" then
            @cookie = login
      end
      return @cookie
end