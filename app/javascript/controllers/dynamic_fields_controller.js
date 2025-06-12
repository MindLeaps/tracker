import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dynamic-fields"
export default class extends Controller {
  static targets = ['select']

  connect() {
    this.updateFilter()
  }

  updateFilter() {
    this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))
  }

  updateDropdown(dropdown, values, parentIds) {
    const currentValue = Number(dropdown.value);
    dropdown.innerHTML = '';

    let valueExists = false;
    const filteredIds = values.filter(v => !parentIds || parentIds.includes(v.depend_id)).map((v) => {
      if (currentValue === v.id) {
        valueExists = true;
      }
      else if (v.grouped_options) {
        v.grouped_options.forEach(o => {
          if(currentValue === o.id) {
            valueExists = true
          }
        })
      }

      if(v.grouped_options)
        dropdown.append(createOptionGroup(v.label, v.grouped_options));
      else
        dropdown.append(createOption(v.label, v.id));

      return v.id;
    });

    if (valueExists) {
      dropdown.value = currentValue;
    }

    const dependents = JSON.parse(dropdown.dataset.dependents || null);

    if (dependents) {
      dependents.forEach(dependentSelectName => {
        const targetSelects = this.selectTargets.filter(t => t.dataset.name === dependentSelectName);

        targetSelects.forEach(ts => {
          this.updateDropdown(ts, JSON.parse(ts.dataset.resources), valueExists ? [currentValue] : filteredIds)
        })
      })
    }
  }
}

function createOption(label, value) {
  const opt = document.createElement('option');

  opt.text = label;

  if (value !== undefined) {
    opt.value = value;
  }

  return opt;
}

function createOptionGroup(label, options) {
  const optgroup = document.createElement('optgroup');

  optgroup.label = label;

  if (options !== undefined) {
    options.forEach( o => {
      optgroup.append(createOption(o.label, o.id))
    })
  }

  return optgroup;
}