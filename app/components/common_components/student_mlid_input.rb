class CommonComponents::StudentMlidInput < ViewComponent::Base
  include ApplicationHelper

  attr_reader :id

  ELEMENT_ID = 'student_mlid_input'.freeze
  def initialize(mlid, student_id: nil, show_label: false)
    @mlid = mlid
    @id = student_id.present? ? "#{ELEMENT_ID}_#{student_id}" : ELEMENT_ID
    @show_label = show_label
  end

  # <%= render ::CommonComponents::ButtonComponent.new(label: 'generate', href: '', options: {data: {'action' => 'click->mlid#manuallyGenerateMlid'}}) %>
  erb_template <<~ERB
    <div id="<%= @id %>" >
        <% if @show_label %>
          <label class="field-label" for="student_mlid">MLID</label>
        <% end %>
        <div class="flex">
        <input class="mt-1 block rounded-l-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm uppercase" maxlength="8" size="10" type="text" value="<%= @mlid %>" name="student[mlid]" id="student_mlid" data-mlid-target="mlid" }>
        <button type="button" data-action="click->mlid#manuallyGenerateMlid" class="-outline-offset-[-1px] flex bg-gray-50 mt-1 shrink-0 items-center gap-x-1.5 rounded-r-md px-3 text-sm font-semibold text-gray-900 outline-solid outline-1 outline-purple-500 hover:bg-gray-100">
          <%= helpers.inline_svg_tag 'refresh.svg', class: 'group-hover:text-white h-5 w-5' %>
        </button>
        </div>
    </div>
  ERB
end
