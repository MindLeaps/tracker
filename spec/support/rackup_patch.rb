# Monkey patch to solve this Capybara error with Puma
#   undefined method `register' for module Rackup::Handler
#
# https://github.com/puma/puma/issues/3558
if Rails.env.test?
  module Rackup
    module Handler
      def self.register(name, klass)
        @handlers ||= {}
        @handlers[name.to_s] = klass
      end
    end
  end
end
