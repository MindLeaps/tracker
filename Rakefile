# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks
require 'rubocop/rake_task'

desc 'Run Rubocop for static analysis of Ruby code'
task :rubocop do
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['-RD']
  end
end

Rake::Task['test'].clear # Overriding Rails default test task which runs minitest
desc 'Run Rubocop and then Spec'
task test: %i[rubocop spec] do
  puts 'Tests OK'
end
