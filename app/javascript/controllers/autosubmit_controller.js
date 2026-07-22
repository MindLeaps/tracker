import { Controller } from "@hotwired/stimulus"
import  debounce  from "lodash.debounce"

// Connects to data-controller="autosubmit"
export default class extends Controller {
  static targets = ["form", "input", "clearButton"]

  connect() {
    this.submit = debounce(this.submit, 200).bind(this)
    this.updateClearButton()
  }

  submit(e) {
    this.formTarget.requestSubmit();
  }

  clear() {
    this.inputTarget.value = ""
    this.updateClearButton()
    this.formTarget.requestSubmit()
    this.inputTarget.focus()
  }

  updateClearButton() {
    if (!this.hasClearButtonTarget || !this.hasInputTarget) return
    this.clearButtonTarget.classList.toggle("hidden", this.inputTarget.value.length === 0)
  }
}
