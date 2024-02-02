import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transition"
export default class extends Controller {
  static values = {
    toggle: String
  }
  connect() {
    setTimeout(() => this.element.classList.remove(...this.toggleValue.split(' ')), 1)
  }

  close(e) {
    e.preventDefault()
    setTimeout(() => this.element.classList.add(...this.toggleValue.split(' ')), 1)
    setTimeout(() => this.element.remove(), 200)
  }
}
