import { Controller } from '@hotwired/stimulus'

function createOption(label, value) {
  const opt = document.createElement('option');
  opt.text = label;
  if (value !== undefined) {
    opt.value = value;
  }

  return opt;
}

export default class extends Controller {
  static targets = ['select', 'anchor']

  connect() {
    this.updateFilter()
  }

  updateFilter() {
    this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))
    this.anchorTarget.href = this.selectTargets.reduce((acc, e) => {
      return acc + e.getAttribute('data-name') + '=' + this.toId(e.value) + '&'
    }, '?')
  }

  toId(value) {
    if (Number.isNaN(Number(value))) {
      return ''
    }
    return value
  }

  updateDropdown(dropdown, values, parentIds) {
    const currentValue = Number(dropdown.value);
    dropdown.innerHTML = '';
    dropdown.append(createOption('All', null));

    let valueExists = false;
    const filteredIds = values.filter(v => !parentIds ||
        parentIds.includes(v.depend_id) ||
        ( v.dependendt_ids && v.dependent_ids.some(id => parentIds.includes(id))))
      .map((v) => {
        if (currentValue === v.id) {
          valueExists = true;
        }
        dropdown.append(createOption(v.label, v.id));
        return v.id;
    });

    if (valueExists) {
      dropdown.value = currentValue;
    }

    const dependents = JSON.parse(dropdown.dataset.dependents || null);
    if (dependents) {
      dependents.forEach(dependentSelectName => {
        const targetSelect = this.selectTargets.find(t => t.dataset.name === dependentSelectName);
        this.updateDropdown(targetSelect, JSON.parse(targetSelect.dataset.resources), valueExists ? [currentValue] : filteredIds)
      })
    }
  }
}
