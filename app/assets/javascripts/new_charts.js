//= require chartjs.js
//= require regression.js

function whiteBackgroundPlugin() {
    return {
        id: "whiteBackground",
        beforeDraw: (chart) => {
            const { ctx, chartArea } = chart
            if (!chartArea) return
            ctx.save()
            ctx.fillStyle = "white"
            ctx.fillRect(chartArea.left, chartArea.top, chartArea.right - chartArea.left, chartArea.bottom - chartArea.top)
            ctx.restore()
        }
    }
}

function polynomialLineForGroup(group, order = 4) {
    if (!window.regression) {
        console.error("regression-js not found (window.regression undefined).")
        return null
    }

    // Ensure numeric + sorted
    const pts = (group.data || [])
        .map(p => ({ x: Number(p.x), y: Number(p.y) }))
        .filter(p => Number.isFinite(p.x) && Number.isFinite(p.y))
        .sort((a, b) => a.x - b.x)

    if (pts.length < order + 1) return null

    const xs = pts.map(p => p.x)
    const minX = Math.min(...xs)
    const maxX = Math.max(...xs)
    const span = maxX - minX
    if (span === 0) return null

    // Map x -> t in [-1, 1]
    const toT = (x) => ((x - minX) / span) * 2 - 1
    const toX = (t) => minX + ((t + 1) / 2) * span

    // Fit polynomial on t to avoid instability
    const data = pts.map(p => [toT(p.x), p.y])
    const result = window.regression.polynomial(data, { order })

    // Sample a smooth curve in t-space
    const steps = 200
    const curve = []
    for (let i = 0; i <= steps; i++) {
        const t = -1 + (2 * i) / steps
        const y = result.predict(t)[1]
        curve.push({ x: toX(t), y })
    }

    return curve
}

function colorForIndex(i) {
    const colors = ["#4F46E5", "#16A34A", "#DC2626", "#D97706", "#0891B2", "#7C3AED", "#DB2777", "#111827"]
    return colors[i % colors.length]
}

function buildDatasetsForGroups(groups) {
    const datasets = []

    groups.forEach((g, idx) => {
        const c = colorForIndex(idx)

        // 1) scatter points
        datasets.push({
            label: g.name,
            type: "scatter",
            data: (g.data || []).map(p => ({
                x: p.x,
                y: p.y,
                lesson_url: p.lesson_url,
                date: p.date
            })),
            pointRadius: 3,
            backgroundColor: c,
            borderColor: c
        })

        // 2) polynomial regression line for that group
        const curve = polynomialLineForGroup(g, 4)
        if (curve) {
            datasets.push({
                label: `${g.name} - Regression`,
                type: "line",
                data: curve,
                pointRadius: 0,
                borderWidth: 2,
                borderColor: c,
                backgroundColor: c,
                tension: 0
            })
        }
    })

    return datasets
}

function displayAveragePerformancePerGroupByLesson(groups) {
    const canvas = document.getElementById("groups-performance-chart")
    if (!canvas) return

    if (!window.Chart) {
        console.error("Chart.js not found (window.Chart undefined).")
        return
    }

    const datasets = buildDatasetsForGroups(groups)

    if (canvas.__chart) canvas.__chart.destroy()

    canvas.__chart = new Chart(canvas.getContext("2d"), {
        data: { datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            clip: false,
            plugins: {
                legend: { display: true },
                tooltip: {
                    backgroundColor: "#ffffff",
                    titleColor: "#111827",
                    bodyColor: "#374151",
                    borderColor: "#D1D5DB",
                    borderWidth: 2,
                    cornerRadius: 3,
                    padding: 12,
                    titleFont: {
                        size: 14,
                        weight: '600'
                    },
                    bodyFont: {
                        size: 13
                    },
                    bodySpacing: 3,
                    callbacks: {
                        title: function(context){
                            if(context[0].dataset.type === 'line') return null
                            return context[0].dataset.label
                        },

                        label: function(context) {
                            if (context.dataset.type === "line") return null

                            const raw = context.raw || {}
                            const x = context.parsed.x
                            const y = context.parsed.y
                            const parts = [`Lesson Number: ${x}`, `Average: ${y}`]

                            if (raw.date) {
                                parts.push(`Date: ${raw.date}`)
                            }

                            return parts
                        }
                    }
                }
            },
            scales: {
                x: {
                    min: 1,
                    title: { display: true, text: "Nr. of lessons" },
                    ticks: { precision: 0 }
                },
                y: {
                    title: { display: true, text: "Performance" },
                    min: 1,
                    max: 7,
                    ticks: { precision: 0 }
                }
            },
            onClick: function (_evt, elements) {
                if (!elements || elements.length === 0) return
                const el = elements[0]
                const ds = this.data.datasets[el.datasetIndex]

                // ignore regression line clicks
                if (ds.type === "line") return

                const point = ds.data[el.index]
                if (point && point.lesson_url) window.open(point.lesson_url, "_blank")
            }
        },
        plugins: [whiteBackgroundPlugin]
    })
}