import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['close'];
    connect() {
        setTimeout(() => {
            this.element.classList.add('notification-in');
            this.element.classList.remove('notification-out');
        }, 1)
    }

    close() {
        setTimeout(() => {
        this.element.classList.add('notification-out');
        this.element.classList.remove('notification-in');
        }, 1)
        setTimeout(() => this.element.remove(), 200);
    }
}