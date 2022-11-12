import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['close'];
    connect() {
        this.element.classList.add('notification-in');
        this.element.classList.remove('notification-out');
    }

    close() {
        this.element.classList.add('notification-out');
        this.element.classList.remove('notification-in');
        setTimeout(() => this.element.remove(), 200);
    }
}