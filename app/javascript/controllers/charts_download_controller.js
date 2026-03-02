import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="charts_download"
export default class extends Controller {
    static targets = ["canvas"]
    static values = { title: String }

    download() {
        const canvas = this.canvasTarget
        const chart = canvas.__chart

        // ensure latest changes
        if (chart) {
            chart.update("none")
        }

        // Best quality + correct filename: use toBlob
        canvas.toBlob((blob) => {
            if (!blob) {
              return
            }

            const url = URL.createObjectURL(blob)
            const a = document.createElement("a")

            a.href = url
            a.download = this.titleValue
            document.body.appendChild(a)
            a.click()
            a.remove()
            URL.revokeObjectURL(url)
        }, "image/png")
    }
}
