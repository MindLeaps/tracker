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
  static targets = ['select', 'anchor', 'multiselect']

  connect() {
    this.updateFilter()
  }

  updateFilter() {
    // filter dropdowns
    this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))

    // filter multiselect dropdowns
    this.updateMultiselectOptions()

    // update anchor link
    this.updateAnchor()
  }

  updateAnchor() {
    const params = new URLSearchParams()

    // add select params
    this.selectTargets.forEach(e => {
      const value = this.toId(e.value)
      params.set(e.getAttribute('data-name'), value)
    })

    // add multiselect params (hidden inputs)
    this.multiselectTargets.forEach(wrapper => {
      const inputs = wrapper.querySelectorAll('input[type="hidden"]')
      inputs.forEach(i => {
        if (i.value !== '') params.append(i.name, i.value)
      })
    })

    this.anchorTarget.href = `?${params.toString()}`
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
    const filteredIds = values.filter(v => !parentIds || parentIds.includes(v.depend_id) || (v.dependent_ids && v.dependent_ids.some(id => parentIds.includes(id))))
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

  updateMultiselectOptions() {
    // your selects are: organization_id, chapter_id
    const chapterSelect = this.selectTargets.find(t => t.dataset.name === "chapter_id")
    const chapterId = this.toId(chapterSelect?.value)

    // Parent ids used for filtering multi selectable groups:
    // - if chapter selected => filter by chapter
    const parentIds = chapterId ? [chapterId] : []

    this.multiselectTargets.forEach(wrapper => {
      const el = wrapper.querySelector('[data-controller~="multiselect"]')
      if (!el) return

      const controller = this.application.getControllerForElementAndIdentifier(el, "multiselect")
      controller?.filterOptions(parentIds)
    })
  }
}
