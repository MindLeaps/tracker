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
        // Count only the visible columns
        const visibleCount = this.columns.filter(c => c.displayed).length

        // Update the grid dynamically (Tailwind grid-cols-* cannot be changed dynamically)
        this.grid.style.gridTemplateColumns = `repeat(${visibleCount}, minmax(0, 1fr))`
    }
}
