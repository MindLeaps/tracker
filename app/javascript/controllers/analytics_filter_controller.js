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
  static targets = ['select', 'anchor', 'multiselect', 'date', 'studentSelect']

  connect() {
    this.allowedIdsByName = {}
    this.updateFilter()
  }

  updateFilter() {
    // filter dropdowns
    this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))

    // filter multiselect dropdown
    this.updateMultiselectOptions()

    // update anchor link
    this.updateAnchor()
  }

  updateAnchor() {
    const params = new URLSearchParams()

    // add select params
    this.selectTargets.forEach(e => {
      const value = this.toId(e.value)
      const name = e.getAttribute('data-name')

      if (value !== '') params.set(name, value)
    })

    // add multiselect params (hidden inputs)
    this.multiselectTargets.forEach(wrapper => {
      const inputs = wrapper.querySelectorAll('input[type="hidden"]')
      inputs.forEach(i => {
        if (i.value !== '') params.append(i.name, i.value)
      })
    })

    // add date params
    this.dateTargets.forEach(wrapper => {
      const inputs = wrapper.querySelectorAll('input')
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
    if (!dropdown || !values) return // return if dropdown has no resources

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

    // store allowed ids for this select to use in multiselect component
    this.allowedIdsByName[dropdown.dataset.name] = filteredIds

    if (valueExists) {
      dropdown.value = currentValue;
    }

    const dependents = JSON.parse(dropdown.dataset.dependents || null);
    if (dependents) {
      dependents.forEach(dependentSelectName => {
        const targetSelect = this.selectTargets.find(t => t.dataset.name === dependentSelectName);

        if(targetSelect){
          this.updateDropdown(targetSelect, JSON.parse(targetSelect.dataset.resources), valueExists ? [currentValue] : filteredIds)
        }
      })
    }
  }

  updateMultiselectOptions() {
    // possible select dropdowns are for: organization_id, chapter_id
    const orgSelect = this.selectTargets.find(t => t.dataset.name === "organization_id")
    const chapterSelect = this.selectTargets.find(t => t.dataset.name === "chapter_id")
    const orgId = this.toId(orgSelect?.value) // "" when All
    const chapterId = this.toId(chapterSelect?.value) // "" when All

    let allowedChapterIds = []

    if (chapterId) {
      // specific chapter selected
      allowedChapterIds = [chapterId]
    } else if (orgId) {
      // specific org selected, chapter = All => use the allowed chapters computed by updateDropdown
      allowedChapterIds = (this.allowedIdsByName["chapter_id"] || []).map(String)
    } else {
      // org = All and chapter = All => no filtering, show all groups
      allowedChapterIds = []
    }

    this.multiselectTargets.forEach(wrapper => {
      const el = wrapper.querySelector('[data-controller~="multiselect"]')

      if (!el) {
        return
      }

      const controller = this.application.getControllerForElementAndIdentifier(el, "multiselect")
      controller?.filterOptions(allowedChapterIds)
    })
  }

  async preloadStudents() {
    // Find hidden inputs for group_ids[] in any multiselect wrapper
    const wrapper = this.multiselectTargets.find(m => m.querySelector('input[type="hidden"][name="group_ids[]"]'))
    if (!wrapper) return

    const selectedGroupIds = [...wrapper.querySelectorAll('input[type="hidden"][name="group_ids[]"]')]
        .map(i => i.value)
        .filter(v => v !== '')

    await this.loadStudentsForGroupIds(selectedGroupIds)
    this.updateAnchor()
  }

  async loadStudentsForGroupIds(groupIds) {
    const studentSelect = this.studentSelectTarget
    const url = studentSelect.dataset.studentsUrl
    const ids = (groupIds || []).map(String).filter(v => v !== '')

    if (ids.length === 0) {
      this.resetStudentSelect()
      return
    }

    // load students
    studentSelect.disabled = true
    studentSelect.innerHTML = ''
    studentSelect.append(createOption('Loading...', ''))

    const params = new URLSearchParams()
    ids.forEach(id => params.append('group_ids[]', id))

    const resp = await fetch(`${url}?${params.toString()}`, {
      headers: { Accept: 'application/json' }
    })

    if (!resp.ok) {
      this.resetStudentSelect()
      return
    }

    const students = await resp.json()

    studentSelect.innerHTML = ''
    studentSelect.append(createOption('All', ''))
    students.forEach(s => studentSelect.append(createOption(s.label, s.id)))

    studentSelect.disabled = false
    this.applySelectedStudentIfPresent()

    // If no preselected student, reset to All (useful when groups change)
    if (!studentSelect.value) {
      studentSelect.value = ''
    }
  }

  applySelectedStudentIfPresent() {
    const studentSelect = this.studentSelectTarget
    const selectedId = String(studentSelect.dataset.selectedStudentId || '').trim()
    if (!selectedId) return

    // only set if the option exists
    const hasOption = [...studentSelect.options].some(o => String(o.value) === selectedId)
    if (hasOption) {
      studentSelect.value = selectedId
    }
  }

  resetStudentSelect(message = 'Select groups to load students') {
    const studentSelect = this.studentSelectTarget

    studentSelect.innerHTML = ''
    studentSelect.append(createOption(message, ''))
    studentSelect.disabled = true
    studentSelect.value = ''
  }

  // called when group multiselect changes
  async handleGroupChange(event) {
    // event.detail: { name, selected }
    if (event.detail?.name === 'group_ids[]') {
      await this.loadStudentsForGroupIds(event.detail.selected || [])
    }

    this.updateAnchor()
  }
}
