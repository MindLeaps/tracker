require 'rspec/core/formatters/progress_formatter'
class SpecOrderLogger < RSpec::Core::Formatters::ProgressFormatter
  RSpec::Core::Formatters.register self, :example_started
  def example_started(notification)
    File.open('log/spec_order.log', 'a+') do |f|
      f.write("#{notification.example.location}\n")
    end
  end
end
