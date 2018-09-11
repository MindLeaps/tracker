# frozen_string_literal: true

class JsonLimitBacktrace < SemanticLogger::Formatters::Json
  def exception
    return unless log.exception

    super
    # limits the stack trace length to 10 lines
    hash[:exception][:stack_trace] = hash[:exception][:stack_trace].take 10
    hash[:message] = hash[:exception][:message]
  end
end
