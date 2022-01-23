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
      chipSpan.className = 'mdl-chip mdl-chip--deletable'

      const chipText = document.createElement('span');
      chipText.className = 'mdl-chip__text'
      const text = document.createTextNode(tag.label);
      chipText.appendChild(text);
      chipSpan.appendChild(chipText);

      const chipButton = document.createElement('button');
      chipButton.className = 'mdl-chip__action'
      chipButton.type = 'button'
      console.log(this.deleteImageUrlValue);
      chipButton.innerHTML = '<img src="' + this.deleteImageUrlValue + '" />';
      chipButton.addEventListener('click', (_) => this.removeTagWithValue(tag.value));
      chipSpan.appendChild(chipButton);

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
