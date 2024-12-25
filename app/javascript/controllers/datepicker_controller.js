import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {
    static values = { date: String }
    connect() {
       const picker = new Pikaday({
           field: document.getElementById('datepicker'),
           format: 'YYYY-MM-DD',
           minDate: new Date(Date.parse('1970-01-01')),
           maxDate: new Date(),
           onSelect: (date) => {
               this.dateValue = date
           }
       });

       // for some reason setting the defaultDate through the constructor does not work
       picker.setDate(this.dateValue)
    }
}
