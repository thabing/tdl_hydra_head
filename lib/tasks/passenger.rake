require 'fileutils'

namespace :passenger do
  desc "Restart Application"
  task :restart do
    FileUtils.touch "#{RAILS_ROOT}/tmp/restart.txt"
  end
end
