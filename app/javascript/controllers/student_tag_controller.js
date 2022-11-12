import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tags', 'autocomplete', 'container']
  static values = { deleteImageUrl: String }
  autocomplete = null

  addTag(tag) {
    const tagToAdd = this.getOptions().find(function(option) {
      return option.value === tag.value;
    })
    tagToAdd.setAttribute('selected', 'selected');
    this.renderTags();
  }

  removeTagWithValue(value) {
    const tagToRemove = this.getOptions().find(function(option) {
      return option.value === value;
    });
    tagToRemove.removeAttribute('selected');
    this.renderTags();
  }

  getOptions() {
    return Array.prototype.slice.call(this.tagsTarget.getElementsByTagName('option'));
  }

  getOptionsToDisplayInAutocomplete() {
    return this.getOptions().filter((option) => {
      return !option.selected;
    });
  }

  formatOptions(options) {
    return options.map((option) => {
      return {value: option.value, label: option.innerText};
    });
  }

  updateAutocomplete() {
    this.autocomplete.list = this.formatOptions(this.getOptionsToDisplayInAutocomplete());
  }

  renderTags() {
    this.containerTarget.innerHTML = '';
    const tags = this.formatOptions(this.getOptions().filter((option) => option.selected === true));

    tags.forEach((tag) => {
      const chipSpan = document.createElement('span');
      chipSpan.className = 'inline-flex rounded-full bg-purple-800 pl-3 mr-2 mb-2 text-sm font-medium text-purple-100'

      const labelSpan = document.createElement('span')
      labelSpan.className = 'py-0.5 mr-3'
      labelSpan.innerText = tag.label;

      const deleteButton = document.createElement('span')
      deleteButton.className = 'rounded-r-full bg-red-800 pr-2 py-0.5 text-sm font-medium text-purple-100'
      deleteButton.innerHTML = '<svg class="ml-1 h-5 w-5 text-indigo-400 cursor-pointer" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="white"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>'

      chipSpan.appendChild(labelSpan);
      chipSpan.appendChild(deleteButton);

      deleteButton.addEventListener('click', (_) => this.removeTagWithValue(tag.value));
      this.containerTarget.appendChild(chipSpan);
    });

    this.updateAutocomplete();
  }

  connect() {
    this.autocomplete = new Awesomplete(this.autocompleteTarget, {
      list: this.formatOptions(this.getOptionsToDisplayInAutocomplete()),
      minChars: 0
    });

    this.autocompleteTarget.addEventListener('focus', () => {
      this.autocomplete.evaluate();
    });

    this.autocompleteTarget.addEventListener('keydown', (e) => {
      if (e.keyCode === 13) {
        e.preventDefault();
      }
    });

    this.autocompleteTarget.addEventListener('awesomplete-selectcomplete', (e) => {
      this.addTag(e.text);
      this.autocompleteTarget.value = '';
      this.autocomplete.evaluate();
    });
    this.renderTags();
  }
}
