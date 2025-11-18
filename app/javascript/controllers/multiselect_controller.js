import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multiselect"
export default class extends Controller {
    static targets = ["menu", "option", "hiddenField", "label"]
    static values = { label: String, selectName: String }

    connect() {
        // Collect initial values from hidden inputs
        this.selected = [...this.hiddenFieldTarget.querySelectorAll("input")].map(input => input.value)
        this.applyInitialSelection()
        this.updateLabel()

        // Close menu if anything outside is clicked
        this.outsideClick = this.handleClickOutside.bind(this)
        document.addEventListener("click", this.outsideClick)
    }

    disconnect() {
        document.removeEventListener("click", this.outsideClick)
    }

    handleClickOutside(event) {
        if (!this.element.contains(event.target)) {
            this.menuTarget.classList.add("hidden")
        }
    }

    applyInitialSelection() {
        this.optionTargets.forEach(opt => {
            const id = opt.dataset.value

            if (this.selected.includes(id)) {
                opt.classList.add("text-green-600")
                opt.querySelector(".checkmark").classList.remove("hidden")
            }
        })
    }

    toggleMenu(event) {
        event.stopPropagation()
        this.menuTarget.classList.toggle("hidden")
    }

    toggleOption(event) {
        const item = event.currentTarget
        const id = item.dataset.value

        if (this.selected.includes(id)) {
            this.selected = this.selected.filter(s => s !== id)
            item.classList.remove("text-green-600")
            item.querySelector(".checkmark").classList.add("hidden")
        } else {
            this.selected.push(id)
            item.classList.add("text-green-600")
            item.querySelector(".checkmark").classList.remove("hidden")
        }

        this.rebuildHiddenInputs()
        this.updateLabel()
    }

    rebuildHiddenInputs() {
        this.hiddenFieldTarget.innerHTML = ""

        if(this.selected.length ===0){
            const blank = document.createElement("input")
            blank.type = "hidden"
            blank.name = this.selectNameValue
            blank.value = ''
            this.hiddenFieldTarget.appendChild(blank)
            return
        }

        this.selected.forEach(id => {
            const input = document.createElement("input")
            input.type = "hidden"
            input.name = this.selectNameValue
            input.value = id
            this.hiddenFieldTarget.appendChild(input)
        })
    }

    updateLabel() {
        if (this.selected.length === 0) {
            this.labelTarget.textContent = this.labelValue
        } else {
            this.labelTarget.textContent = `${this.selected.length} selected`
        }
    }
}
