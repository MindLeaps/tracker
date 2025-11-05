import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static values = { columns: Array }

    connect() {
        this.grid = this.element
        this.columns = this.columnsValue

        this.columns.forEach(c => {
            const toggle = document.getElementById(`${c.id}Toggle`);
            if (!toggle) return;

            toggle.addEventListener("click", () => {
                const toggled = toggle.getAttribute("data-toggled");
                c.displayed = !!toggled;

                this.updateGridColumns()
            });
        });

        this.updateGridColumns()
    }

    updateGridColumns() {
        const visibleCount = this.columns.filter(c => c.displayed).length
        this.grid.style.gridTemplateColumns = `repeat(${visibleCount}, minmax(0, 1fr))`
    }
}
