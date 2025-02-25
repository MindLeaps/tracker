//= require chart.js

const whiteBackgroundOnDownload = {
    id: 'customCanvasBackgroundColor',
    beforeDraw: (chart, args, options) => {
        const {ctx} = chart;
        ctx.save();
        ctx.globalCompositeOperation = 'destination-over';
        ctx.fillStyle = options.color || '#99ffff';
        ctx.fillRect(0, 0, chart.width, chart.height);
        ctx.restore();
    }
};

const generatePerformanceChart = (dataSeries, chartId) => {
    let dataSets = []
    let maxIndex = 0

    dataSeries.forEach(s => {
        let numberOfPoints = s.series[0].data.length
        let seriesColor = "#" + ((1 << 24) * Math.random() | 0).toString(16).padStart(6, "0")

        dataSets.push({
            label: s.series[0].name,
            data: s.series[0].data.map(dataPoint => ({ x: dataPoint.x, y: dataPoint.y, date: dataPoint.date, url: dataPoint.lesson_url })),
            fill: false,
            borderColor:  seriesColor,
            borderWidth: 4 - (0.1 * dataSeries.length),
            tension: 0.2
        })

        if(numberOfPoints > maxIndex) maxIndex = numberOfPoints
    })

    let performanceChart = new Chart(document.getElementById(chartId), {
        type: 'line',
        data: {
            labels: Array.from({ length: maxIndex }, (x, i) => i + 1),
            datasets: dataSets
        },
        options: {
            clip: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Average Performance versus number of Lessons',
                    fullSize: true,
                    padding: 20,
                    font: {
                        size: 20
                    }
                },
                legend: {
                    display: true,
                    position: 'bottom',
                },
                customCanvasBackgroundColor: {
                    color: 'white',
                },
                tooltip: {
                    enabled: true,
                    callbacks: {
                        title: () => '',
                        label: (item) => {
                            return item.dataset.label
                        },
                        beforeFooter: (item) => {
                            return 'Lesson Date: ' + item[0].raw.date
                        },
                        footer: (item) => {
                            return 'Average Mark: ' + item[0].formattedValue
                        }
                    }
                }
            },
            scales: {
                x: {
                    title:{
                        display: true,
                        text: 'Number of Lessons',
                        font: {
                            size: 20
                        }
                    },
                    ticks: {
                        padding: 8,
                        font: {
                            size: 14
                        },
                    }
                },
                y: {
                    title:{
                        display: true,
                        text: 'Score',
                        font: {
                            size: 20
                        }
                    },
                    beginAtZero: true,
                    min: 1,
                    max: 7,
                    ticks: {
                        padding: 5,
                    }
                }
            },
            animation: {
                onComplete: () => {
                    const downloadAnchor = document.getElementById('performanceDownloadLink')
                    downloadAnchor.href = performanceChart.toBase64Image();
                    downloadAnchor.download = 'Performance_Chart.png';
                }
            }
        },
        plugins: [whiteBackgroundOnDownload]
    });

    updateChartContainerDimensions(chartId)
}

const generateAttendanceChart = (dataSeries, chartId) => {
    let dataSets = []

    dataSeries.forEach(s => {
        let seriesColor = "#" + ((1 << 24) * Math.random() | 0).toString(16).padStart(6, "0")

        dataSets.push({
            label: s.series[0].name,
            data: s.series[0].data.map(dataPoint => ({ x: dataPoint.date, y: dataPoint.attendance === true ? 100 : dataPoint.attendance, date: dataPoint.date, url: dataPoint.lesson_url })),
            backgroundColor:  seriesColor,
            borderColor: seriesColor,
            barPercentage: 0.5,
            categoryPercentage: 1,
            tension: 0.2
        })
    })

    let attendanceChart = new Chart(document.getElementById(chartId), {
        type: dataSeries[0].series[0].is_student_series ? 'line' : 'bar',
        data: {
            datasets: dataSets
        },
        options: {
            clip: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Attendance during the Program',
                    fullSize: true,
                    padding: 20,
                    font: {
                        size: 20
                    }
                },
                legend: {
                    display: true,
                    position: 'bottom',
                },
                customCanvasBackgroundColor: {
                    color: 'white',
                },
                tooltip: {
                    enabled: true,
                    callbacks: {
                        title: () => '',
                        label: (item) => {
                            return item.dataset.label
                        },
                        beforeFooter: (item) => {
                            return 'Lesson Date: ' + item[0].raw.date
                        },
                        footer: (item) => {
                            return 'Attendance: ' + item[0].formattedValue + '%'
                        }
                    }
                }
            },
            scales: {
                x: {
                    title:{
                        display: true,
                        text: 'Lesson Date',
                        font: {
                            size: 20
                        }
                    },
                    ticks: {
                        padding: 6,
                        font: {
                            size: 12
                        },
                    }
                },
                y: {
                    title:{
                        display: true,
                        text: 'Attendance',
                        font: {
                            size: 20
                        }
                    },
                    beginAtZero: true,
                    max: 100,
                    ticks: {
                        padding: 5,
                    }
                }
            },
            animation: {
                onComplete: () => {
                    const downloadAnchor = document.getElementById('attendanceDownloadLink')
                    downloadAnchor.href = attendanceChart.toBase64Image();
                    downloadAnchor.download = 'Attendance_Chart.png';
                }
            }
        },
        plugins: [whiteBackgroundOnDownload]
    });

    updateChartContainerDimensions(chartId)
}


const updateChartContainerDimensions = (chartId) => {
    const chart = document.getElementById(chartId)
    const container = document.getElementById('chartContainer')

    container.style.height = chart.style.height
}