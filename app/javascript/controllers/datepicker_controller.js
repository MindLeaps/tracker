import { Controller } from "@hotwired/stimulus"
import * as pikaday from 'pikaday'

// Connects to data-controller="datepicker"
export default class extends Controller {
    static values = { date: String, enabledDates: Array }
    static targets = [ "picker", "anchor" ]

    updateFilter() {
        let newDate = this.pickerTarget.value
        let url = new URL(this.anchorTarget.href)

        url.searchParams.set("selected_date", newDate)
        this.anchorTarget.href = url.href
    }

    onChange() {
        this.element.dispatchEvent(new CustomEvent("datepicker:change", { bubbles: true }))
    }

    connect() {
       const formatDate = (date) => {
           const parts = [date.getFullYear(), ('0'+(date.getMonth()+1)).slice(-2), ('0'+date.getDate()).slice(-2)];
           return parts.join("-");
       }
       const enabledDates = this.hasEnabledDatesValue && this.enabledDatesValue.length > 0 ? new Set(this.enabledDatesValue) : null

       const picker = new Pikaday({
           field: this.pickerTarget,
           minDate: new Date(Date.parse('1970-01-01')),
           maxDate: new Date(),
           format: 'YYYY-MM-DD',
           toString: formatDate,
           parse(dateString, format) {
               // dateString is the result of the `toString` method
               const parts = dateString.split('-');
               const year = parseInt(parts[0]);
               const month = parseInt(parts[1]) - 1;
               const day = parseInt(parts[2]);
               return new Date(year, month, day);
           },
           disableDayFn: enabledDates ? (date) => !enabledDates.has(formatDate(date)) : undefined
       });
    }
}
