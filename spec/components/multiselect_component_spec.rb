RSpec.describe CommonComponents::MultiselectComponent, type: :component do
  before :each do
    @label = 'Select Items'
    @options = [{ id: 1, label: 'First Item' }, { id: 2, label: 'Second Item' }, { id: 3, label: 'Third Item' }]
    @target = 'some_target'
  end

  it 'has the correct label' do
    render_inline(CommonComponents::MultiselectComponent.new(label: @label, target: @target, options: @options))
    expect(page).to have_css('button', text: @label, visible: true)
  end

  it 'contains all options' do
    render_inline(CommonComponents::MultiselectComponent.new(label: @label, target: @target, options: @options))
    rendered_options = page.find_all('div[data-multiselect-target="option"] > span', visible: false)

    @options.each_with_index do |option, index|
      expect(rendered_options[index].text).to eq option[:label]
    end
  end

  it 'renders inputs for already selected options' do
    selected_values = [@options[0][:id], @options[1][:id]]
    render_inline(CommonComponents::MultiselectComponent.new(label: @label, target: @target, options: @options, selected_values: selected_values))

    hidden_inputs = page.find_all('div[data-multiselect-target="hiddenField"] > input', visible: false)

    selected_values.each_with_index do |value, index|
      expect(hidden_inputs[index].value).to eq value.to_s
    end
  end
end
