import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {
    static values = { date: String, id: String }
    connect() {
       const picker = new Pikaday({
           field: document.getElementById(this.idValue),
           format: 'YYYY-MM-DD',
           minDate: new Date(Date.parse('1970-01-01')),
           maxDate: new Date(),
           defaultDate: this.dateValue,
           setDefaultDate: true,
           onSelect: (date) => {
               this.dateValue = date

               console.log(this.dateValue)
           }
       });

       // setting the default date to be shown
       picker.setDate(this.dateValue)
    }
}
