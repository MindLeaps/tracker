//= require chart.js

const colors = ['#e6194B', '#3cb44b', '#ffe119' , '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45',
    '#fabed4', '#469990' ,'#dcbeff', '#9A6324', '#fffac8' ,'#800000' ,'#aaffc3' ,'#808000' ,'#ffd8b1', '#000075' ,'#a9a9a9', '#ffffff', '#000000']
const getColorFromIndex = (index) => colors[index % colors.length]
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

        dataSets.push({
            label: s.series[0].name,
            data: s.series[0].data.map(dataPoint => ({ x: dataPoint.x, y: dataPoint.y, date: dataPoint.date, url: dataPoint.lesson_url })),
            fill: false,
            borderColor:  s.color,
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

        dataSets.push({
            label: s.series[0].name,
            data: s.series[0].data.map(dataPoint => ({ x: dataPoint.date, y: dataPoint.attendance === true ? 100 : dataPoint.attendance, date: dataPoint.date, url: dataPoint.lesson_url })),
            backgroundColor:  s.color,
            borderColor: s.color,
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

const generateSkillChart = (dataSeries, chartId, skillName) => {
    let dataSets = []
    let maxIndex = 0

    dataSeries.forEach(s => {
        let numberOfPoints = s.data.length

        dataSets.push({
            label: s.name,
            data: s.data.map(dataPoint => ({ x: dataPoint.x, y: dataPoint.y, date: dataPoint.date, url: dataPoint.lesson_url })),
            fill: false,
            borderColor: s.color,
            borderWidth: 4 - (0.1 * dataSeries.length),
            tension: 0.2
        })

        if(numberOfPoints > maxIndex) maxIndex = numberOfPoints
    })

    new Chart(document.getElementById(chartId), {
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
                    text: skillName,
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
                            return 'Average Skill Mark: ' + item[0].formattedValue
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

            }
        },
        plugins: [whiteBackgroundOnDownload]
    });

    updateChartContainerDimensions(chartId)
}

const generateStudentSkillChart = (dataSeries, chartId, studentName) => {
    let dataSets = []
    let maxIndex = 0

    console.log(dataSeries)

    dataSeries.forEach((s,index) => {
        let numberOfPoints = s.data.length

        dataSets.push({
            label: s.skill_name,
            data: s.data.map(dataPoint => ({ x: dataPoint.x, y: dataPoint.y, date: dataPoint.date, url: dataPoint.lesson_url })),
            fill: false,
            borderColor: getColorFromIndex(index),
            borderWidth: 4 - (0.1 * dataSeries.length),
            tension: 0.1,
            hidden: index !== 0
        })

        if(numberOfPoints > maxIndex) maxIndex = numberOfPoints
    })

    let studentChart = new Chart(document.getElementById(chartId), {
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
                    text: studentName,
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
                        title: () => 'Marko',
                        label: (item) => {
                            return item.dataset.label
                        },
                        beforeFooter: (item) => {
                            return 'Lesson Date: ' + item[0].raw.date
                        },
                        footer: (item) => {
                            return 'Skill Mark: ' + item[0].formattedValue
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
                    const downloadAnchor = document.getElementById('skillDownloadLink')
                    downloadAnchor.href = studentChart.toBase64Image();
                    downloadAnchor.download = `${studentName}_Skill_Chart.png`;
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

const setDownloadLink = () => {
    const downloadAnchor = document.getElementById('skillDownloadLink')
    downloadAnchor.href = skillChart.toBase64Image();
    downloadAnchor.download = 'Skill_Chart.png';
}