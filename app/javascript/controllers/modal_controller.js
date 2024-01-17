import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ['backdrop', 'modal']
  connect() {
    setTimeout(() => {
      this.backdropTarget.classList.add('backdrop-in')
      this.backdropTarget.classList.remove('backdrop-out')
      this.modalTarget.classList.add('modal-in')
      this.modalTarget.classList.remove('modal-out')
    }, 30)
  }

  stopPropagation(e) {
    e.stopPropagation()
  }

  close(e) {
    this.backdropTarget.classList.add('backdrop-out')
    this.backdropTarget.classList.remove('backdrop-in')
    this.modalTarget.classList.add('modal-out')
    this.modalTarget.classList.remove('modal-in')
    setTimeout(() => {
      this.element.innerHTML = '';
    }, 300)
  }
}
