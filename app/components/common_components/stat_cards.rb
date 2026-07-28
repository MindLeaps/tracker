class CommonComponents::StatCards < ViewComponent::Base
  def initialize(stats:, columns:, label: nil)
    @stats = stats
    @columns = columns
    @label = label
  end

  erb_template <<~ERB
    <div>
      <% if @label %>
        <h2 class="py-1 bg-purple-700 text-white inline-block ml-6 px-3 rounded-t-lg"><%= @label %></h2>
      <% end %>
      <dl class="grid grid-cols-<%= @columns %> gap-5">
        <% @stats.each do |stat| %>
          <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-sm sm:p-6">
            <dt class="text-sm font-medium text-gray-500"><%= stat[:title] %>:</dt>
            <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= stat[:value] %></dd>
          </div>
        <% end %>
      </dl>
    </div>
  ERB
end
