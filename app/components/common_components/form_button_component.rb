class CommonComponents::FormButtonComponent < ViewComponent::Base
  def initialize(label:, method:, path: nil, params: nil, options: {})
    @label = label
    @path = path
    @method = method
    @params = params
    @options = options
  end
end
