import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['mlid', 'group']

    groupSelect() {
        if ((!this.hasMlidTarget || this.mlidTarget.value === '') && this.groupTarget.value) {
            this.generateMlid()
        }
    }

    manuallyGenerateMlid(e) {
        e.preventDefault()
        this.generateMlid()
    }

    generateMlid() {
            let groupId = this.groupTarget.value
            fetch('/students/mlid/' + groupId, {
                headers: { 'Accept': 'text/vnd.turbo-stream.html'}
            }).then(r => r.text()).then(html => Turbo.renderStreamMessage(html))
    }
}
