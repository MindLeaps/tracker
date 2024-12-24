import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {
    static targets = ['datepicker']
    connect() {
       const picker = new Pikaday({
           field: document.getElementById('datepicker'),
           format: 'YYYY/MMM/D',
           toString(date, format) {
               // you should do formatting based on the passed format,
               // but we will just return 'D/M/YYYY' for simplicity
               const day = date.getDate();
               const month = date.getMonth() + 1;
               const year = date.getFullYear();
               return `${year}/${month}/${day}`;
           }
       });
    }
}
