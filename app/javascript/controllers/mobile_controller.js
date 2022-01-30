import { Controller } from "@hotwired/stimulus"

const rootOpenClasses = ['flex']
const rootClosedClasses = ['pointer-events-none']
const overlayOpenClasses = ['opacity-100']
const overlayClosedClasses = ['opacity-0']
const sidebarOpenClasses = ['translate-x-0']
const sidebarClosedClasses = ['-translate-x-full']
const buttonOpenClasses = ['opacity-100']
const buttonClosedClasses = ['opacity-0']

export default class extends Controller {
  static targets = ['root', 'overlay', 'sidebar', 'button']

  sidebarOpen = false
  connect() {
    this.handleSidebar()
  }

  handleSidebar() {
    if (this.sidebarOpen) {
      this.openSidebar()
    } else {
      this.closeSidebar()
    }
  }

  openSidebar() {
    rootClosedClasses.forEach(c => this.rootTarget.classList.remove(c))
    rootOpenClasses.forEach(c => this.rootTarget.classList.add(c))
    overlayClosedClasses.forEach(c => this.overlayTarget.classList.remove(c))
    overlayOpenClasses.forEach(c => this.overlayTarget.classList.add(c))
    sidebarClosedClasses.forEach(c => this.sidebarTarget.classList.remove(c))
    sidebarOpenClasses.forEach(c => this.sidebarTarget.classList.add(c))
    buttonClosedClasses.forEach(c => this.buttonTarget.classList.remove(c))
    buttonOpenClasses.forEach(c => this.buttonTarget.classList.add(c))
    this.sidebarOpen = true
  }

  closeSidebar() {
    rootOpenClasses.forEach(c => this.rootTarget.classList.remove(c))
    rootClosedClasses.forEach(c => this.rootTarget.classList.add(c))
    overlayOpenClasses.forEach(c => this.overlayTarget.classList.remove(c))
    overlayClosedClasses.forEach(c => this.overlayTarget.classList.add(c))
    sidebarOpenClasses.forEach(c => this.sidebarTarget.classList.remove(c))
    sidebarClosedClasses.forEach(c => this.sidebarTarget.classList.add(c))
    buttonOpenClasses.forEach(c => this.buttonTarget.classList.remove(c))
    buttonClosedClasses.forEach(c => this.buttonTarget.classList.add(c))
    this.sidebarOpen = false
  }

  toggleSidebar() {
    this.sidebarOpen = !this.sidebarOpen
    this.handleSidebar()
  }
}
