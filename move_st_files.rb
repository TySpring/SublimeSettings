# USAGE:
# ======================================================================
# + To "dump" settings FROM Sublime Text into this repo:
#   sudo ruby move_st_files.rb action=DUMP ST_DIR=...
#
# + To "load" settings INTO Sublime Text from this repo:
#   sudo ruby move_st_files.rb action=LOAD ST_DIR=...
#
# + ST_DIR is the path to your Sublime Text prefs folder, for example:
#   ST_DIR="/Users/tylerdavis/Library/Application Support/Sublime Text 3"
# ======================================================================

require 'fileutils'

def get_arg(arg_name)
  ARGV.detect { |arg| arg.include?("#{arg_name}=") }.split('=').last
end

ST_DIR = (ENV['ST_DIR'] || get_arg('ST_DIR')).freeze
USER_SETTINGS = "#{ST_DIR}/Packages/User".freeze
SAVED_PREFS = File.expand_path(File.dirname(__FILE__)).freeze

ACTIONS = %w(LOAD DUMP)

def main
  validate_action

  action = get_arg('action')

  return from_sublime_to_repo if action == 'DUMP'
  return from_repo_to_sublime if action == 'LOAD'
end

def validate_action
  unless ACTIONS.include?(get_arg('action').upcase)
    fail ArgumentError, 'an "action=..." argument must be supplied. See the Readme.'
  end
end

# move files from saved repo to ST user prefs
def from_repo_to_sublime
  copy_to_sublime("#{SAVED_PREFS}/settings")
  copy_to_sublime("#{SAVED_PREFS}/snippets")
  copy_to_sublime("#{SAVED_PREFS}/packages")
end

def copy_to_sublime(original_dir)
  copy_files(Dir.glob("#{original_dir}/*"), USER_SETTINGS)
end

# move files from ST user prefs to this repo
def from_sublime_to_repo
  copy_files(packages_files, "#{SAVED_PREFS}/packages")
  copy_files(settings_files, "#{SAVED_PREFS}/settings")
  copy_files(snippets_files, "#{SAVED_PREFS}/snippets")
end

def packages_files
  user_settings_files('Package Control.sublime-settings')
end

def settings_files
  extensions = ['*.sublime-keymap', '*.sublime-mousemap', '*.sublime-settings', '*.py']
  user_settings_files(*extensions)
end

def snippets_files
  user_settings_files('*.sublime-snippet')
end

def user_settings_files(*extensions)
  extensions.map do |extension|
    Dir.glob("#{USER_SETTINGS}/#{extension}")
  end.flatten
end


def copy_files(files, dest_dir)
  FileUtils.cp(files, dest_dir)
end

#dewitdew
main
