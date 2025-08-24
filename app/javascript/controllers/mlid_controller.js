import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['mlid', 'organization']
    static values = {
        showLabel: Boolean,
        studentId: Number
    }

    initialize() {
        if ((!this.hasMlidTarget || this.mlidTarget.value === '') && this.organizationTarget.value) {
            this.generateMlid()
        }
    }

    organizationSelect() {
        if ((!this.hasMlidTarget || this.mlidTarget.value === '') && this.organizationTarget.value) {
            this.generateMlid()
        }
    }

    manuallyGenerateMlid(e) {
        e.preventDefault()
        this.generateMlid()
    }

    generateMlid() {
            let organizationId = this.organizationTarget.value
            let url = '/students/mlid/' + organizationId

            if (this.studentIdValue) {
                url += `?student_id=${this.studentIdValue}`
            }
            if (this.showLabelValue) {
                url += '?show_label'
            }

            fetch(url, {
                headers: { 'Accept': 'text/vnd.turbo-stream.html'}
            }).then(r => r.text()).then(html => Turbo.renderStreamMessage(html))
    }
}
