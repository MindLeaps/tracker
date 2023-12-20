import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="skill-form"
export default class extends Controller {
  static targets = [ "grade" ];
  delete() {
    const element = event.target;
    element.parentElement.parentElement.remove();
  }
}
