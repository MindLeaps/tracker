# frozen_string_literal: true

task stats: 'st'

task st: :environment do
  require 'rails/code_statistics'
  ::STATS_DIRECTORIES << ['Policies', 'app/policies']
  ::STATS_DIRECTORIES << ['Serializers', 'app/serializers']
  ::STATS_DIRECTORIES << ['Services', 'app/services']

  # Order main code before test code
  ::STATS_DIRECTORIES.sort! do |a, b|
    if a[0].include?('specs') && !b[0].include?('specs')
      1
    elsif !a[0].include?('specs') && b[0].include?('specs')
      -1
    else
      a[0] <=> b[0]
    end
  end
end
