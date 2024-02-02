import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="association"
export default class extends Controller {
  static targets = [ "removable", "checkable" ];
  remove(event) {
    event.stopPropagation();
    event.preventDefault();
    let removeTarget = this.removableTargets.find(e => e.id === event.params.removeId);
    removeTarget.classList.add('hidden');
    let checkableTarget = this.checkableTargets.find(e => e.dataset.associationId === event.params.removeId);
    checkableTarget.checked = true;
  }
}
