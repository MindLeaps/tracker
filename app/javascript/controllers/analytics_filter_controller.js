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
  static targets = ['select', 'anchor', 'multiselect', 'date']

  connect() {
    this.allowedIdsByName = {}
    this.updateFilter()
  }

  updateFilter(event) {
    const changedName = event?.target?.dataset?.name

    // filter dropdowns
    this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))

    // filter multiselect dropdown
    this.updateMultiselectOptions()

    // refresh student dropdown if org or chapter changed
    if (changedName === "organization_id" || changedName === "chapter_id") {
      this.refreshStudentsForCurrentGroups()
    }

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
      // org = All, and chapter = All => no filtering, show all groups
      allowedChapterIds = []
    }

    this.multiselectTargets.forEach(wrapper => {
      const el = wrapper.querySelector('[data-controller~="multiselect"]')

      if (!el) {
        return
      }

      if (el.dataset.multiselectSelectNameValue !== "group_ids[]") {
        return
      }

      const controller = this.application.getControllerForElementAndIdentifier(el, "multiselect")
      controller?.filterOptions(allowedChapterIds)
    })
  }

  resetStudents() {
    const frame = document.getElementById('student_select_frame')
    if (!frame) return

    frame.src = `${frame.dataset.srcBase}`
    frame.reload()
  }

  refreshStudentsForCurrentGroups() {
    const groupIds = this.readSelectedGroups()
    if (groupIds.length === 0) {
      this.resetStudents()
      return
    }

    // reload frame according to groups
    const frame = document.getElementById('student_select_frame')
    if (!frame) return

    const params = new URLSearchParams()
    groupIds.forEach(id => params.append('group_ids[]', id))
    params.set('multiple', 'true')

    // keep current student selection if possible
    this.readSelectedStudents().forEach(id => params.append('student_ids[]', id))

    frame.src = `${frame.dataset.srcBase}?${params.toString()}`
    frame.reload()
  }

  preloadStudents() {
    const frame = document.getElementById('student_select_frame')
    if (!frame) return

    const groupIds = this.readSelectedGroups()
    if (groupIds.length === 0) return

    const params = new URLSearchParams()
    groupIds.forEach(id => params.append('group_ids[]', id))
    params.set('multiple', 'true')

    // preserve student_ids from url
    const urlParams = new URLSearchParams(window.location.search)
    const studentIds = urlParams.getAll('student_ids[]')
    if (studentIds.length > 0) {
      studentIds.forEach(id => params.append('student_ids[]', id))
    } else {
      const studentId = urlParams.get('student_id')
      if (studentId) params.append('student_ids[]', studentId)
    }

    frame.src = `${frame.dataset.srcBase}?${params.toString()}`
    frame.reload()
  }

  readSelectedGroups() {
    const wrapper = this.multiselectTargets.find(mt => mt.querySelector('input[type="hidden"][name="group_ids[]"]'))
    if (!wrapper) return []

    return [...wrapper.querySelectorAll('input[type="hidden"][name="group_ids[]"]')]
        .map(i => i.value)
        .filter(v => v !== '')
  }

  readSelectedStudents() {
    const wrapper = this.multiselectTargets.find(mt => mt.querySelector('input[type="hidden"][name="student_ids[]"]'))
    if (wrapper) {
      return [...wrapper.querySelectorAll('input[type="hidden"][name="student_ids[]"]')]
          .map(i => i.value)
          .filter(v => v !== '')
    }

    const studentSelect = this.selectTargets.find(t => t.dataset.name === 'student_id')
    return studentSelect?.value ? [studentSelect.value] : []
  }

  // called when group multiselect changes
  handleGroupChange(event) {
    if (event.detail?.name !== 'group_ids[]') return

    const frame = document.getElementById('student_select_frame')
    if (!frame) return

    const params = new URLSearchParams();

    (event.detail.selected || [])
        .filter(v => v !== '')
        .forEach(id => params.append('group_ids[]', id))
    params.set('multiple', 'true')

    // keep current student selection if possible
    this.readSelectedStudents().forEach(id => params.append('student_ids[]', id))

    frame.src = `${frame.dataset.srcBase}?${params.toString()}`
    frame.reload()

    this.updateAnchor()
  }
}
