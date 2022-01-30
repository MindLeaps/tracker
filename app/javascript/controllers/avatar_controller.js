import { Controller } from "@hotwired/stimulus"

const enterClasses = ['ease-out', 'duration-100', 'opacity-100', 'scale-100', 'pointer-events-auto']
const exitClasses = ['ease-in', 'duration-75', 'opacity-0', 'scale-95', 'pointer-events-none']

export default class extends Controller {
  static targets = ['dropdown', 'button']

  dropdownOpen = false
  connect() {
    this.handleDropdown()
  }

  handleDropdown() {
    if (this.dropdownOpen) {
      this.openDropdown()
    } else {
      this.closeDropdown()
    }
  }

  openDropdown() {
    exitClasses.forEach(c => this.dropdownTarget.classList.remove(c))
    enterClasses.forEach(c => this.dropdownTarget.classList.add(c))
  }

  closeDropdown(event) {
    if (event && this.buttonTarget.contains(event.target)) {
      return true;
    }
    enterClasses.forEach(c => this.dropdownTarget.classList.remove(c))
    exitClasses.forEach(c => this.dropdownTarget.classList.add(c))
    this.dropdownOpen = false
  }

  toggleDropdown() {
    this.dropdownOpen = !this.dropdownOpen
    this.handleDropdown()
  }
}