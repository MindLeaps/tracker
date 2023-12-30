import { Controller } from "@hotwired/stimulus"
import  debounce  from "lodash.debounce"

// Connects to data-controller="autosubmit"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.submit = debounce(this.submit, 200).bind(this)
  }

  submit(e) {
    this.formTarget.requestSubmit();
  }
}
