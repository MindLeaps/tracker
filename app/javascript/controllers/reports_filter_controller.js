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
    static values = {
        path: String
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

    updateFilter() {
        this.updateDropdown(this.selectTargets[0], JSON.parse(this.selectTargets[0].dataset.resources))
        const replaceValue = this.toId(this.selectTargets[this.selectTargets.length - 1].value)
        this.anchorTarget.href = this.pathValue.replace("placeholder", replaceValue)
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
                this.updateDropdown(targetSelect, JSON.parse(targetSelect.dataset.resources), valueExists ? [currentValue] : filteredIds)
            })
        }
    }
}
