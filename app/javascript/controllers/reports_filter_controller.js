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
    static targets = ['select', 'anchor', 'studentAnchor']
    static values = {
        path: String,
        studentPath: String
    }

    connect() {
        this.updateFilter()
    }

    toId(value) {
        if (Number.isNaN(Number(value))) {
            return ''
        }
        return value
    }

    updateFilter(event) {
        this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))

        const changedName = event?.target?.dataset?.name
        if (changedName === 'organization_id' || changedName === 'chapter_id' || changedName === 'group_id') {
            this.refreshStudents()
        }

        this.updateAnchors()
    }

    updateAnchor() {
        this.updateAnchors()
    }

    updateAnchors() {
        const groupSelect = this.selectTargets.find(t => t.dataset.name === 'group_id')
        const studentSelect = this.selectTargets.find(t => t.dataset.name === 'student_id')

        const groupId = this.toId(groupSelect?.value)
        const studentId = this.toId(studentSelect?.value)

        this.anchorTarget.href = groupId ? this.pathValue.replace("placeholder", groupId) : "#"
        groupId ? this.enableAnchor(this.anchorTarget) : this.disableAnchor(this.anchorTarget)

        if (this.hasStudentAnchorTarget) {
            this.studentAnchorTarget.href = studentId ? this.studentPathValue.replace("placeholder", studentId) : "#"
            studentId ? this.enableAnchor(this.studentAnchorTarget) : this.disableAnchor(this.studentAnchorTarget)
        }
    }

    updateDropdown(dropdown, values, parentIds) {
        const currentValue = Number(dropdown.value);
        dropdown.innerHTML = '';
        const dependents = JSON.parse(dropdown.dataset.dependents || null);
        if (dependents) {
            dropdown.append(createOption('All', null));
        }

        let valueExists = false;
        const filteredIds = values.filter(v => !parentIds || parentIds.includes(v.depend_id)).map((v) => {
            if (currentValue === v.id) {
                valueExists = true;
            }
            dropdown.append(createOption(v.label, v.id));
            return v.id;
        });

        if (valueExists) {
            dropdown.value = currentValue;
        }

        if (dependents) {
            dependents.forEach(dependentSelectName => {
                const targetSelect = this.selectTargets.find(t => t.dataset.name === dependentSelectName);
                if (targetSelect) {
                    this.updateDropdown(
                        targetSelect,
                        JSON.parse(targetSelect.dataset.resources),
                        valueExists ? [currentValue] : filteredIds
                    )
                }
            })
        }
    }

    refreshStudents() {
        const frame = document.getElementById('student_select_frame')
        if (!frame) return

        const groupSelect = this.selectTargets.find(t => t.dataset.name === 'group_id')
        const groupId = this.toId(groupSelect?.value)

        if (!groupId) {
            frame.src = frame.dataset.srcBase
            frame.reload()
            this.updateAnchors()
            return
        }

        const params = new URLSearchParams()
        params.append('group_ids[]', groupId)

        const studentSelect = this.selectTargets.find(t => t.dataset.name === 'student_id')
        const currentStudentId = this.toId(studentSelect?.value)
        if (currentStudentId) params.set('student_id', currentStudentId)

        frame.src = `${frame.dataset.srcBase}?${params.toString()}`
        frame.reload()
    }

    disableAnchor(anchor) {
        anchor.style.pointerEvents = "none"
        anchor.style.cursor = "default"
        anchor.style.opacity = "0.5"
    }

    enableAnchor(anchor) {
        anchor.style.pointerEvents = ""
        anchor.style.cursor = "pointer"
        anchor.style.opacity = "1"
    }
}