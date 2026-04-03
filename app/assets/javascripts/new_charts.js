//= require chartjs.js
//= require regression.js

// ---------- Shared Helpers ----------
function chartJsPresent() {
    if (!window.Chart) {
        console.error("Chart.js not found (window.Chart undefined).")
        return false
    } else return true
}

function whiteBackgroundPlugin() {
    return {
        id: "whiteBackground",
        beforeDraw: (chart, args, options) => {
            const { ctx, canvas } = chart

            ctx.save()
            ctx.globalCompositeOperation = "destination-over"
            ctx.fillStyle = (options && options.color) ? options.color : "white"
            ctx.fillRect(0, 0, canvas.width, canvas.height)
            ctx.restore()
        }
    }
}

function todayLinePlugin() {
    return {
        id: "todayLine",
        afterDraw(chart, args, opts) {
            const xScale = chart.scales.x
            if (!xScale) return

            const { ctx, chartArea } = chart
            const today = opts?.timestampMs ?? Date.now()
            const x = xScale.getPixelForValue(today)

            if (x < chartArea.left || x > chartArea.right) return

            ctx.save()
            ctx.lineWidth = 2
            ctx.setLineDash([6, 6])
            ctx.strokeStyle = opts?.color ?? "#ef4444"
            ctx.beginPath()
            ctx.moveTo(x, chartArea.top)
            ctx.lineTo(x, chartArea.bottom)
            ctx.stroke()
            ctx.restore()
        }
    }
}

function ensureCanvasIsPresent(containerSelector, opts = {}) {
    const id = containerSelector.startsWith("#") ? containerSelector.slice(1) : containerSelector
    const container = document.getElementById(id)
    if (!container) return null

    if (container.tagName.toLowerCase() === "canvas") return container

    let canvas = container.querySelector("canvas")
    if (canvas) return canvas

    canvas = document.createElement("canvas")
    canvas.style.width = "100%"
    canvas.style.height = (opts.heightPx ? `${opts.heightPx}px` : "500px")

    // Keep Stimulus download target support
    if ((container.dataset.controller || "").includes("charts-download")) {
        canvas.setAttribute("data-charts-download-target", "canvas")
    }

    // insert canvas after the download button if present, otherwise append
    const btn = container.querySelector('button[data-action*="charts-download#download"]')
    if (btn && btn.parentNode === container) {
        btn.insertAdjacentElement("afterend", canvas)
    } else {
        container.appendChild(canvas)
    }

    return canvas
}

function destroyIfExists(canvas) {
    if (canvas && canvas.__chart) {
        canvas.__chart.destroy()
        canvas.__chart = null
    }
}

function toUSdateFormat(date) {
    const d = (date instanceof Date) ? date : new Date(date)
    return d.toLocaleDateString("en-US")
}

function colorForIndex(i) {
    const colors = ["#7cb5ec", "#434348", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#2b908f", "#f45b5b", "#91e8e1"]

    return colors[i % colors.length]
}

function withAlpha(hex, a) {
    // accepts "#RRGGBB"
    const r = parseInt(hex.slice(1, 3), 16)
    const g = parseInt(hex.slice(3, 5), 16)
    const b = parseInt(hex.slice(5, 7), 16)

    return `rgba(${r}, ${g}, ${b}, ${a})`
}

function dynamicPointRadius(len, { min = 1, max = 4 } = {}) {
    if (!len || len <= 0) return max
    const r = 12 / Math.sqrt(len)
    return Math.max(min, Math.min(max, r))
}

function polynomialLineForGroup(group, order = 4) {
    if (!window.regression) {
        console.error("regression-js not found (window.regression undefined).")
        return null
    }

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

    const toT = (x) => ((x - minX) / span) * 2 - 1
    const toX = (t) => minX + ((t + 1) / 2) * span

    const data = pts.map(p => [toT(p.x), p.y])
    const result = window.regression.polynomial(data, { order })

    const steps = 200
    const curve = []

    for (let i = 0; i <= steps; i++) {
        const t = -1 + (2 * i) / steps
        const rawY = result.predict(t)[1]
        const y = Math.max(1, Math.min(7, rawY))

        curve.push({ x: toX(t), y })
    }

    return curve
}

function buildDatasetsForGroups(groups) {
    const datasets = []

    groups.forEach((g, idx) => {
        const color = colorForIndex(idx)

        // 1) scatter points
        datasets.push({
            label: g.name,
            type: "scatter",
            groupKey: g.id,
            data: (g.data || []).map(p => ({
                x: p.x,
                y: p.y,
                lesson_url: p.lesson_url,
                date: p.date
            })),
            pointRadius: 2,
            backgroundColor: color,
            borderColor: color
        })

        // 2) polynomial regression line for that group
        const curve = polynomialLineForGroup(g, 4)
        if (curve) {
            datasets.push({
                label: `${g.name} - Regression`,
                groupKey: g.id,
                type: "line",
                data: curve,
                pointRadius: 0,
                borderWidth: 3,
                borderColor: withAlpha(color, .75),
                borderDash: [5, 5],
                tension: 0,
                hiddenFromLegend: true
            })
        }
    })

    return datasets
}

function buildDatasetsForStudentReportByGroups(groupedData) {
    const source = groupedData ? groupedData : {}
    const datasets = []

    Object.entries(source).forEach(([groupId, rows], idx) => {
        const color = colorForIndex(idx)
        const firstRow = rows[0] || {}

        const points = rows
            .map((row) => {
                const x = new Date(row.lesson_date).getTime()
                const y = row.average_mark

                return {
                    x,
                    y,
                    date: row.lesson_date,
                    lesson_url: row.lesson_url,
                    group_id: row.group_id,
                    group_name: row.group_name
                }
            })

        if (!points.length) return

        datasets.push({
            label: firstRow.group_name || `Group ${groupId}`,
            groupKey: groupId,
            type: "line",
            data: points,
            parsing: false,
            borderColor: color,
            backgroundColor: color,
            borderWidth: 3,
            tension: 0.15,
            spanGaps: false,
            pointRadius: 3,
            pointHoverRadius: 5
        })
    })

    return datasets
}

function buildRegressionOnlyDatasetsForStudentSkills(skillSeriesJson, opts = {}) {
    const items = Array.isArray(skillSeriesJson) ? skillSeriesJson : []
    const datasets = []

    items.forEach((item, idx) => {
        const skillName = item?.skill || `Skill ${idx + 1}`
        const firstSeries = Array.isArray(item?.series) ? item.series[0] : null
        const color = firstSeries?.color || colorForIndex(idx)

        const points = (firstSeries?.data || [])
            .map((p) => ({
                x: p.x,
                y: p.y,
                lesson_url: p.lesson_url,
                date: p.date
            }))
            .sort((a, b) => a.x - b.x)

        if (points.length < 2) return

        const group = {
            id: skillName,
            name: skillName,
            data: points
        }

        const curve = polynomialLineForGroup(group, opts.regressionOrder ?? 4)
        if (!curve) return

        datasets.push({
            label: skillName,
            type: "line",
            data: curve,
            parsing: false,
            borderColor: color,
            backgroundColor: color,
            borderDash: [5, 5],
            borderWidth: 3,
            tension: 0,
            pointRadius: 0,
            pointHoverRadius: 0
        })
    })

    return datasets
}

// ---------- Group Analytics Chart && Average performance per Group by Lesson chart ---------
function displayAveragePerformancePerGroupByLessonChart(containerId, seriesJson, opts = {}) {
    if(!chartJsPresent()) return

    const series = Array.isArray(seriesJson) ? seriesJson : []

    // Convert "series" -> "groups" that buildDatasetsForGroups expects
    const groups = series.map((s, idx) => ({
        id: s.id || s.name || String(idx),
        name: s.name || `Group ${idx + 1}`,
        data: (s.data || []).map(p => ({
            x: p.x,
            y: p.y,
            lesson_url: p.lesson_url,
            date: p.date
        }))
    }))

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: opts.heightPx || 500 })
    if (!canvas) return

    destroyIfExists(canvas)

    const datasets = buildDatasetsForGroups(groups)

    new Chart(canvas.getContext("2d"), {
        data: { datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            clip: false,
            animation: {
                duration: 1000,
                easing: "easeOutQuart",
                delay: (ctx) => {
                    if (ctx.type !== "data") return 0
                    const ds = ctx.chart.data.datasets[ctx.datasetIndex]
                    if (ds.type === "line") return 0
                    return ctx.dataIndex * 12
                }
            },
            plugins: {
                title: {
                    display: opts.title,
                    text: opts.title || 'Average performance per Group by Lesson',
                    font: {
                        size: 16
                    }
                },
                legend: {
                    display: true,
                    labels:
                    {
                        padding: 20,
                        font: { size: 13 },
                        filter: (legendItem, chartData) => {
                            const dataSet = chartData.datasets[legendItem.datasetIndex]
                            return !dataSet.hiddenFromLegend
                        }
                    },
                    onClick: (e, legendItem, legend) => {
                        const chart = legend.chart
                        const clickedDataset = chart.data.datasets[legendItem.datasetIndex]

                        // toggle using the clicked dataset's current hidden state
                        const scatterMeta = chart.getDatasetMeta(legendItem.datasetIndex)
                        const nextHidden = !scatterMeta.hidden

                        // apply to all datasets with same groupKey (scatter + regression)
                        chart.data.datasets.forEach((dataset, i) => {
                            if (dataset.groupKey === clickedDataset.groupKey) {
                                chart.getDatasetMeta(i).hidden = nextHidden
                            }
                        })

                        chart.update()
                    }
                },
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
                },
                whiteBackground: {
                    color: 'white'
                }
            },
            scales: {
                x: {
                    min: 1,
                    title: { display: true, text: opts.xTitle || "Nr. of lessons" },
                    ticks: { precision: 0 }
                },
                y: {
                    title: { display: true, text: opts.yTitle || "Performance" },
                    min: 1,
                    max: 7,
                    ticks: { precision: 0 }
                }
            },
            onClick: function (event, elements) {
                if (!elements || elements.length === 0) return
                const el = elements[0]
                const ds = this.data.datasets[el.datasetIndex]

                // ignore regression line clicks
                if (ds.type === "line") return

                const point = ds.data[el.index]
                if (point && point.lesson_url) window.open(point.lesson_url, "_blank")
            },
            onHover: function (event, elements) {
                const canvas = event.native?.target || event.chart?.canvas
                if (!canvas) return

                if (elements.length > 0) {
                    const el = elements[0]
                    const ds = this.data.datasets[el.datasetIndex]

                    canvas.style.cursor = ds.type === "scatter" ? "pointer" : "default"
                } else {
                    canvas.style.cursor = "default"
                }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Averages Chart ----------
function displayAveragesChart(containerId, data) {
    if(!chartJsPresent()) return

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 300 })
    if (!canvas) return

    destroyIfExists(canvas)

    const points = (data || []).map((e, i) => ({
        x: new Date(e.lesson_date).getTime(),
        y: Number(e.average_mark),
        lesson_url: e.lesson_url
    }))

    new Chart(canvas.getContext("2d"), {
        type: "line",
        data: {
            datasets: [{
                data: points,
                parsing: false,
                borderColor: '#9C27B0',
                tension: 0.125,
                pointRadius: dynamicPointRadius(points.length, { min: 3, max: 6 }),
                pointHoverRadius: dynamicPointRadius(points.length, { min: 5, max: 10 })
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    type: "linear",
                    ticks: {
                        callback: (value) => toUSdateFormat(Number(value))
                    }
                },
                y: {
                    min: 1,
                    max: 7,
                    ticks: { precision: 0 }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    borderWidth: 2,
                    cornerRadius: 3,
                    padding: 15,
                    titleFont: {
                        size: 14,
                        weight: '600'
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        title: (ctx) => `Date: ${toUSdateFormat(ctx[0].parsed.x)}`,
                        label: (ctx) => `Average: ${ctx.parsed.y}`
                    }
                },
                whiteBackground: { color: "white" }
            },
            onClick: function (event, elements) {
                if (!elements?.length) return
                const el = elements[0]
                const point = this.data.datasets[el.datasetIndex].data[el.index]
                if (point && point.lesson_url) window.open(point.lesson_url, "_blank")
            },
            onHover: function (event, elements) {
                const c = event.native?.target || event.chart?.canvas
                if (!c) return
                c.style.cursor = elements?.length ? "pointer" : "default"
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Attendance Chart ----------
function displayAttendanceChart(containerId, data) {
    if(!chartJsPresent()) return

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 300 })
    if (!canvas) return

    destroyIfExists(canvas)

    const points = (data || []).map(e => ({
        x: new Date(e.lesson_date).getTime(),
        y: Number(e.attendance)
    }))

    // Start graph one day before first lesson
    let minX = undefined
    if (points.length) {
        const first = new Date(points[0].x)
        const dayBefore = new Date(first.getTime())
        dayBefore.setDate(first.getDate() - 1)
        minX = dayBefore.getTime()
    }

    new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            datasets: [{
                label: "Attendance",
                data: points,
                parsing: false,
                barPercentage: 0.75,
                minBarLength: 2,
                backgroundColor: ' #9C27B0'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    type: "linear",
                    ticks: {
                        callback: (value) => toUSdateFormat(Number(value)),
                    }
                },
                y: {
                    ticks: {
                        callback: (v) => `${v}%`
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    borderWidth: 2,
                    cornerRadius: 3,
                    padding: 15,
                    titleFont: {
                        size: 14,
                        weight: '600'
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        title: (ctx) => `Date: ${toUSdateFormat(ctx[0].parsed.x)}`,
                        label: (ctx) => `Attendance: ${ctx.parsed.y}%`
                    }
                },
                whiteBackground: { color: "white" }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Enrollment Timeline Chart ----------
function displayTimelineChart(containerId, data) {
    if(!chartJsPresent()) return

    const items = (data || []).map((e) => {
        const start = new Date(e.active_since).getTime()
        const endValue = e.effective_end ?? e.inactive_since ?? new Date().toISOString()
        const end = new Date(endValue).getTime()
        return { ...e, start: start, end: end }
    })
    .filter(e => Number.isFinite(e.start) && Number.isFinite(e.end))

    // label duplicates as #2, #3 (multiple enrollments)
    const alreadySeen = new Map()
    items.forEach(it => {
        const n = (alreadySeen.get(it.student_id) || 0) + 1
        alreadySeen.set(it.student_id, n)
        it.rowLabel = n > 1 ? `${it.student_name} #${n}` : it.student_name
    })

    // sort so that duplicates are next to each other
    items.sort((a,b) =>
        a.student_name.localeCompare(b.student_name) ||
        a.start - b.start
    )

    const rowHeight = items.length > 20 ? 16 : 20
    const heightPx = Math.min(1200, Math.max(200, items.length * rowHeight + 40))
    const canvas = ensureCanvasIsPresent(containerId, { heightPx })
    if (!canvas) return

    destroyIfExists(canvas)

    // Floating bar items
    const labels = items.map(i => i.rowLabel)
    const points = items.map((it) => ({
        x: [it.start, it.end],
        y: it.rowLabel,
        inactive_since: it.inactive_since,
        active_since: it.active_since,
        effective_end: it.effective_end
    }))

    const minStart = Math.min(...items.map(i => i.start))
    const maxEnd = Math.max(...items.map(i => i.end))
    const pad = 1000 * 60 * 60 * 24 * 7
    const minX = minStart - pad
    const maxX = maxEnd + pad

    new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            labels,
            datasets: [{
                data: points,
                parsing: { xAxisKey: "x", yAxisKey: "y" },
                indexAxis: "y",
                borderWidth: .5,
                borderRadius: 6,
                barPercentage: 0.4,
                categoryPercentage: 0.65,
                backgroundColor: (ctx) => {
                    const raw = ctx.raw
                    const isActive = raw && (raw.inactive_since == null)
                    return isActive ? " #9C27B0" : withAlpha(" #9C27B0", 0.25)
                }
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            indexAxis: "y",
            scales: {
                x: {
                    type: "linear",
                    min: minX,
                    max: maxX,
                    ticks: { callback: (v) => toUSdateFormat(Number(v)) }
                },
                y: {
                    type: "category",
                    ticks: { autoSkip: false },
                }
            },
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: (ctx) => ctx[0].label || "Enrollment",
                        label: (ctx) => {
                            const raw = ctx.raw || {}
                            const start = raw.x?.[0]
                            const end = raw.x?.[1]
                            const startStr = start ? toUSdateFormat(start) : "-"
                            const endStr = end ? toUSdateFormat(end) : "-"
                            const endLabel = (raw.inactive_since == null) ? `${endStr} (to now)` : endStr
                            return [`Start: ${startStr}`, `End: ${endLabel}`]
                        }
                    }
                },
                todayLine: { color: "#ef4444" },
                whiteBackground: { color: "white" }
            },
            onHover: function (event, elements) {
                const c = event.native?.target || event.chart?.canvas
                if (!c) return
                c.style.cursor = elements?.length ? "pointer" : "default"
            }
        },
        plugins: [whiteBackgroundPlugin(), todayLinePlugin()]
    })
}

// ---------- Lesson Chart ----------
function displayLessonChart(containerId, lessonId, data) {
    if(!chartJsPresent()) return

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 300 })
    if (!canvas) return
    destroyIfExists(canvas)

    const points = (data || []).map(e => ({
            x: e.timestamp * 1000,
            y: e.average_mark,
            lesson_id: e.lesson_id,
            lesson_url: e.lesson_url
        }))
        .sort((a, b) => a.x - b.x)

    // small padding for x
    const xs = points.map(p => p.x)
    const xMin = Math.min(...xs)
    const xMax = Math.max(...xs)

    const pad = (xMax - xMin) * 0.01
    const minX = xMin - pad
    const maxX = xMax + pad

    new Chart(canvas.getContext("2d"), {
        type: "line",
        data: {
            datasets: [{
                data: points,
                parsing: false,
                borderColor: " #9C27B0",
                borderWidth: 4,
                tension: 0.15,
                spanGaps: false,

                // highlight the requested lesson
                pointRadius: (ctx) => {
                    const raw = ctx.raw
                    if (!raw) return 3
                    return raw.lesson_id === lessonId ? 6 : 3
                },
                pointBackgroundColor: (ctx) => {
                    const raw = ctx.raw
                    if (!raw) return "#9C27B0"
                    return raw.lesson_id === lessonId ? "#4CAF50" : " #9C27B0"
                },
                pointBorderColor: (ctx) => {
                    const raw = ctx.raw
                    if (!raw) return "#9C27B0"
                    return raw.lesson_id === lessonId ? "#4CAF50" : " #9C27B0"
                },
                pointHoverRadius: 5
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    type: "linear",
                    min: minX,
                    max: maxX,
                    ticks: {
                        maxTicksLimit: 10,
                        callback: (v) => toUSdateFormat(Number(v))
                    }
                },
                y: {
                    min: 1,
                    max: 7,
                    ticks: { precision: 0 }
                }
            },
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: (ctx) => ` Lesson Date: ${toUSdateFormat(ctx[0].parsed.x)}`,
                        label: (ctx) => ` Average: ${ctx.parsed.y}`
                    }
                },
                whiteBackground: { color: "white" }
            },
            onClick: function (event, elements) {
                if (!elements?.length) return
                const el = elements[0]
                const p = this.data.datasets[el.datasetIndex].data[el.index]
                if (p?.lesson_url) window.location = (p.lesson_url + window.location.search)
            },
            onHover: function (event, elements) {
                const c = event.native?.target || event.chart?.canvas
                if (!c) return
                c.style.cursor = elements?.length ? "pointer" : "default"
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Quantity of Data per Month Graph ----------
function displayAssessmentsPerMonth(containerId, payload, opts = { }) {
    if(!chartJsPresent()) return
    const categories = payload?.categories || []
    const series = payload?.series || []

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 400 })

    if (!canvas) return
    destroyIfExists(canvas)

    const datasets = series.map((s, idx) => ({
        label: s.name || "Assessments",
        data: (s.data || []).map(v => Number(v) || 0),
        borderWidth: 1
    }))

    new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            labels: categories,
            datasets
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'Quantity of Data Collected By Month',
                    font: {
                        size: 16
                    }
                },
                tooltip: {
                    callbacks: {
                        title: (ctx) => `Month: ${ctx[0].label}`,
                        label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y}`
                    }
                },
                whiteBackground: { color: "white" }
            },
            scales: {
                x: {
                    title: { display: true, text: opts.xTitle || "Month" },
                    ticks: { autoSkip: true, maxTicksLimit: 12 }
                },
                y: {
                    beginAtZero: true,
                    ticks: { precision: 0 },
                    title: { display: true, text: opts.yTitle || "Nr. of assessments" }
                }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Student Performance Chart ----------
function displayStudentPerformanceChart(containerId, seriesJson, opts = {}) {
    if(!chartJsPresent()) return

    const series = seriesJson || []
    const first = series[0] || {}
    const name = first.name || "Frequency %"
    const rawPairs = first.data || []

    // generate mark, percentage pairs map
    const map = new Map(rawPairs.map(p => [Number(p?.[0]), Number(p?.[1])]))

    // always show marks 1..7
    const labels = ["1", "2", "3", "4", "5", "6", "7"]
    const values = labels.map(l => map.get(Number(l)) ?? 0)

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 400 })
    if (!canvas) return
    destroyIfExists(canvas)

    new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            labels,
            datasets: [{
                label: name,
                data: values,
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Histogram of Student performance values',
                    font: {
                        size: 16
                    }
                },
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: (ctx) => `${opts.xTitle || "Performance"}: ${ctx[0].label}`,
                        label: (ctx) => `${opts.yTitle || "Frequency %"}: ${ctx.parsed.y.toFixed(1)}%`
                    }
                },
                whiteBackground: { color: "white" }
            },
            scales: {
                x: {
                    title: { display: true, text: opts.xTitle || "Performance" },
                    ticks: { autoSkip: false }
                },
                y: {
                    beginAtZero: true,
                    title: { display: true, text: opts.yTitle || "Frequency %" },
                    ticks: {
                        callback: (v) => `${v}%`
                    }
                }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Student Performance Change Chart ----------
function displayStudentPerformanceChangeChart(containerId, seriesJson, opts = {}) {
    if(!chartJsPresent()) return

    const series = seriesJson || []
    const first = series[0] || {}
    const name = first.name || "Frequency %"
    const rawPairs = first.data || []

    // generate mark, percentage pairs map
    const map = new Map(rawPairs.map(p => [Number(p?.[0]), Number(p?.[1])]))

    // determine bucket range and step
    const xs = Array.from(map.keys()).sort((a, b) => a - b)
    const minX = xs.length ? xs[0] : 0
    const maxX = xs.length ? xs[xs.length - 1] : 0
    const step = opts.step ?? 0.5

    const labels = []
    const values = []

    // fix floating precision issues by iterating integers
    const start = Math.round(minX / step)
    const end = Math.round(maxX / step)

    for (let i = start; i <= end; i++) {
        const x = i * step
        labels.push(x.toFixed(1)) // show -0.5, 0.0, 0.5 ...
        values.push(map.get(x) ?? 0)
    }

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 384 })
    if (!canvas) return
    destroyIfExists(canvas)

    new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            labels,
            datasets: [{
                label: name,
                data: values,
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Performance change throughout the program by Student',
                    font: {
                        size: 16
                    }
                },
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: (ctx) => `${opts.xTitle || "Performance change"}: ${ctx[0].label}`,
                        label: (ctx) => `${opts.yTitle || "Frequency %"}: ${Number(ctx.parsed.y).toFixed(1)}%`
                    }
                },
                whiteBackground: { color: "white" }
            },
            scales: {
                x: {
                    title: { display: true, text: opts.xTitle || "Performance change" },
                    ticks: { autoSkip: true, maxTicksLimit: 12 }
                },
                y: {
                    beginAtZero: true,
                    title: { display: true, text: opts.yTitle || "Frequency %" },
                    ticks: { callback: (v) => `${v}%` }
                }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Performance Change by Gender Chart ----------
function displayPerformanceChangeByGenderChart(containerId, seriesJson, opts = {}) {
    if(!chartJsPresent()) return

    const series = Array.isArray(seriesJson) ? seriesJson : []
    const step = opts.step ?? 0.5

    // collect all x buckets across all series
    const allX = new Set()
    series.forEach(s => {
        (s.data || []).forEach(p => {
            const x = Number(p?.[0])
            if (Number.isFinite(x)) allX.add(x)
        })
    })

    // determine bucket range and steps
    const xs = Array.from(allX).sort((a, b) => a - b)
    const minX = opts.minBucket || (xs.length ? xs[0] : 0)
    const maxX = opts.maxBucket || (xs.length ? xs[xs.length - 1] : 0)

    const start = Math.round(minX / step)
    const end = Math.round(maxX / step)
    const buckets = []
    for (let i = start; i <= end; i++) buckets.push(i * step)

    const labels = buckets.map(x => Number(x).toFixed(1))

    // build datasets to buckets
    const datasets = series.map((s, idx) => {
        const map = new Map((s.data || []).map(p => [p?.[0], p?.[1]]))

        const data = buckets.map(x => map.get(x) ?? 0)

        return {
            label: s.name || `Series ${idx + 1}`,
            data,
            borderWidth: 1
        }
    })

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: 400 })
    if (!canvas) return
    destroyIfExists(canvas)

   new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: { labels, datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Performance change throughout the program separated by Gender',
                    font: {
                        size: 16
                    }
                },
                legend: { display: true },
                tooltip: {
                    callbacks: {
                        title: (ctx) => `Change: ${ctx[0].label}`,
                        label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y.toFixed(1)}%`
                    }
                },
                whiteBackground: { color: "white" }
            },
            scales: {
                x: {
                    title: { display: true, text: opts.xTitle || "Performance change" },
                    ticks: { autoSkip: true, maxTicksLimit: 14 },
                    stacked: false
                },
                y: {
                    beginAtZero: true,
                    title: { display: true, text: opts.yTitle || "Frequency %" },
                    ticks: { callback: (v) => `${v}%` },
                    stacked: false
                }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Subject Skill Chart ----------
function displaySubjectSkillCharts(datasets, opts = {}) {
    if (!chartJsPresent()) return

    const data = Array.isArray(datasets) ? datasets : []

    data.forEach((skillDataset) => {
        const skillName = skillDataset?.skill
        const series = Array.isArray(skillDataset?.series) ? skillDataset.series : []
        if (!skillName) return

        const containerId = `#skill-${skillName}`
        const canvas = ensureCanvasIsPresent(containerId, { heightPx: opts.heightPx || 500 })
        if (!canvas) return
        destroyIfExists(canvas)

        // turn subject series into same format as group series
        const subjectSeriesAsGroups = series.map((s, idx) => ({
            id: s.name || String(idx),
            name: s.name || `Series ${idx + 1}`,
            data: (s.data || []).map(p => ({
                x: Number(p.x),
                y: Number(p.y),
                lesson_url: p.lesson_url,
                date: p.date
            }))
        }))

        const datasetsForChart = buildDatasetsForGroups(subjectSeriesAsGroups)

        new Chart(canvas.getContext("2d"), {
            data: { datasets: datasetsForChart },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                clip: false,
                plugins: {
                    title: {
                        display: true,
                        text: skillName,
                        font: { size: 20 }
                    },
                    legend: {
                        display: true,
                        labels: {
                            padding: 10,
                            font: { size: 11 },
                            boxHeight: 10,
                            boxWidth: 10,
                            filter: (legendItem, chartData) => {
                                const ds = chartData.datasets[legendItem.datasetIndex]
                                return !ds.hiddenFromLegend
                            }
                        },
                        onClick: (e, legendItem, legend) => {
                            const chart = legend.chart
                            const clicked = chart.data.datasets[legendItem.datasetIndex]
                            const meta = chart.getDatasetMeta(legendItem.datasetIndex)
                            const nextHidden = !meta.hidden

                            // toggle scatter + regression for same groupKey
                            chart.data.datasets.forEach((ds, i) => {
                                if (ds.groupKey === clicked.groupKey) {
                                    chart.getDatasetMeta(i).hidden = nextHidden
                                }
                            })

                            chart.update()
                        }
                    },
                    tooltip: {
                        backgroundColor: "#ffffff",
                        titleColor: "#111827",
                        bodyColor: "#374151",
                        borderColor: "#D1D5DB",
                        borderWidth: 2,
                        cornerRadius: 3,
                        padding: 12,
                        callbacks: {
                            title: (ctx) => {
                                const ds = ctx[0]?.dataset
                                if (ds?.type === "line") return null
                                return ds?.label || ""
                            },
                            label: (ctx) => {
                                if (ctx.dataset.type === "line") return null
                                const raw = ctx.raw || {}
                                const parts = [
                                    `${opts.xTitle || "Nr. of lessons"}: ${ctx.parsed.x}`,
                                    `${opts.yTitle || "Performance"}: ${ctx.parsed.y}`
                                ]
                                if (raw.date) parts.push(`${opts.dateLabel || "Lesson date"}: ${raw.date}`)
                                return parts
                            }
                        }
                    },
                    whiteBackground: { color: "white" }
                },
                scales: {
                    x: {
                        min: 1,
                        title: { display: true, text: opts.xTitle || "Nr. of lessons" },
                        ticks: { precision: 0 }
                    },
                    y: {
                        min: 1,
                        max: 7,
                        title: { display: true, text: opts.yTitle || "Performance" },
                        ticks: { precision: 0 }
                    }
                },
                onClick: function (event, elements) {
                    if (!elements?.length) return
                    const el = elements[0]
                    const ds = this.data.datasets[el.datasetIndex]
                    if (ds.type === "line") return

                    const point = ds.data[el.index]
                    if (point?.lesson_url) window.open(point.lesson_url, "_blank")
                },
                onHover: function (event, elements) {
                    const c = event.native?.target || event.chart?.canvas
                    if (!c) return
                    if (!elements?.length) { c.style.cursor = "default"; return }
                    const el = elements[0]
                    const ds = this.data.datasets[el.datasetIndex]
                    c.style.cursor = (ds.type === "scatter") ? "pointer" : "default"
                }
            },
            plugins: [whiteBackgroundPlugin()]
        })
    })
}

// ---------- Mark Averages Chart ----------
function displayMarkAveragesChart(containerId, data, opts = {}) {
    if (!chartJsPresent()) return

    const items = Array.isArray(data) ? data : []

    // build map: mark -> average
    const averageByMark = new Map(items.map(item => [Number(item.mark), Number(item.average)]))

    // always show marks 1..7
    const labels = ["1", "2", "3", "4", "5", "6", "7"]
    const values = labels.map(label => averageByMark.get(Number(label)) ?? 0)

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: opts.heightPx || 500 })
    if (!canvas) return

    destroyIfExists(canvas)

    new Chart(canvas.getContext("2d"), {
        type: "bar",
        data: {
            labels,
            datasets: [{
                label: opts.label || "Mark Averages",
                data: values,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: !!opts.title,
                    text: opts.title || "Mark Percentages",
                    font: {
                        size: 16
                    }
                },
                legend: {
                    display: false
                },
                tooltip: {
                    callbacks: {
                        title: (ctx) => `${opts.xTitle || "Mark"}: ${ctx[0].label}`,
                        label: (ctx) => `${opts.yTitle || "Percentage"}: ${(Number(ctx.parsed.y) * 100).toFixed(1)}%`
                    }
                },
                whiteBackground: { color: "white" }
            },
            scales: {
                x: {
                    title: {
                        display: true,
                        text: opts.xTitle || "Mark"
                    },
                    ticks: {
                        autoSkip: false
                    }
                },
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: opts.yTitle || "Percentage"
                    },
                    ticks: {
                        callback: (value) => `${(Number(value) * 100).toFixed(1)}%`
                    }
                }
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Student report chart: performance by lesson split by group ----------
function displayStudentReportPerformanceByGroupChart(containerId, groupedData, opts = {}) {
    if (!chartJsPresent()) return

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: opts.heightPx || 500 })
    if (!canvas) return

    destroyIfExists(canvas)

    const datasets = buildDatasetsForStudentReportByGroups(groupedData)

    new Chart(canvas.getContext("2d"), {
        data: { datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            clip: false,
            plugins: {
                legend: {
                    display: true,
                    labels: {
                        padding: 10,
                        font: { size: 12 }
                    }
                },
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
                        weight: "600"
                    },
                    bodyFont: {
                        size: 13
                    },
                    bodySpacing: 3,
                    callbacks: {
                        title: function(context) {
                            return context[0].dataset.label
                        },
                        label: function(context) {
                            return [
                                `Date: ${toUSdateFormat(context.parsed.x)}`,
                                `Average: ${context.parsed.y}`
                            ]
                        }
                    }
                },
                whiteBackground: {
                    color: "white"
                }
            },
            scales: {
                x: {
                    type: "linear",
                    title: {
                        display: true,
                        text: opts.xTitle || "Lesson date"
                    },
                    ticks: {
                        callback: (value) => toUSdateFormat(Number(value))
                    }
                },
                y: {
                    title: {
                        display: true,
                        text: opts.yTitle || "Performance"
                    },
                    min: 1,
                    max: 7,
                    ticks: {
                        precision: 0
                    }
                }
            },
            onClick: function(event, elements) {
                if (!elements?.length) return

                const el = elements[0]
                const point = this.data.datasets[el.datasetIndex].data[el.index]

                if (point?.lesson_url) window.open(point.lesson_url, "_blank")
            },
            onHover: function(event, elements) {
                const c = event.native?.target || event.chart?.canvas
                if (!c) return
                c.style.cursor = elements?.length ? "pointer" : "default"
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}

// ---------- Student report chart: performance by lesson split by skill ----------
function displayStudentSkillRegressionChart(containerId, skillSeriesJson, opts = {}) {
    if (!chartJsPresent()) return

    const canvas = ensureCanvasIsPresent(containerId, { heightPx: opts.heightPx || 500 })
    if (!canvas) return
    destroyIfExists(canvas)

    const datasets = buildRegressionOnlyDatasetsForStudentSkills(skillSeriesJson, opts)

    new Chart(canvas.getContext("2d"), {
        data: { datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            clip: false,
            plugins: {
                title: {
                    display: true,
                    text: opts.title || "Student progress by skill",
                    font: { size: 20 }
                },
                legend: {
                    display: true,
                    labels: {
                        padding: 10,
                        font: { size: 11 },
                        boxHeight: 10,
                        boxWidth: 10
                    }
                },
                tooltip: {
                    backgroundColor: "#ffffff",
                    titleColor: "#111827",
                    bodyColor: "#374151",
                    borderColor: "#D1D5DB",
                    borderWidth: 2,
                    cornerRadius: 3,
                    padding: 12,
                    callbacks: {
                        title: (ctx) => ctx[0]?.dataset?.label || "",
                        label: (ctx) => [
                            `${opts.xTitle || "Nr. of lessons"}: ${Math.round(ctx.parsed.x)}`,
                            `${opts.yTitle || "Performance"}: ${ctx.parsed.y.toFixed(2)}`
                        ]
                    }
                },
                whiteBackground: { color: "white" }
            },
            scales: {
                x: {
                    type: "linear",
                    min: 1,
                    title: { display: true, text: opts.xTitle || "Nr. of lessons" },
                    ticks: { precision: 0 }
                },
                y: {
                    min: 1,
                    max: 7,
                    title: { display: true, text: opts.yTitle || "Performance" },
                    ticks: { precision: 0 }
                }
            },
            onHover: function (event) {
                const c = event.native?.target || event.chart?.canvas
                if (!c) return
                c.style.cursor = "default"
            }
        },
        plugins: [whiteBackgroundPlugin()]
    })
}