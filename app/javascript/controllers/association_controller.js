import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="association"
export default class extends Controller {
  static targets = [ "removable" ];
  remove(event) {
    event.stopPropagation();
    event.preventDefault();
    let removeTarget = this.removableTargets.find(e => e.id === event.params.removeId);
    removeTarget.remove();
  }
}
