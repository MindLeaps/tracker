import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['select', 'anchor']

  connect() {
    this.generateUrl()
  }

  generateUrl() {
    this.anchorTarget.href = this.selectTargets.reduce((acc, e) => {
      return acc + e.getAttribute('data-name') + '=' + this.toId(e.value) + '&'
    }, '?')
  }

  toId(value) {
    if (Number.isNaN(Number(value))) {
      return ''
    }
    return value
  }
}
