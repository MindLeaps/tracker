//= require chartist
//= require frappe-gantt

function displayLessonGraph(containerId, lessonId, data) {
  new Chartist.Line(containerId, {
    series: [
      {
        data: data.map(function(e) {
          return {
            x: e.timestamp,
            y: e.average_mark,
            meta: {
              lesson_id: e.lesson_id,
              lesson_url: e.lesson_url
            }
          };
        })
      }
    ]
  }, {
    axisX: {
      type: Chartist.FixedScaleAxis,
      divisor: 5,
      labelInterpolationFnc: function (value) {
        return new Date(value * 1000).toLocaleDateString('en-US');
      }
    },
    axisY: {
      onlyInteger: true
    },
    low: 1,
    high: 7,
    plugins: [
      function(chart) {
        chart.on('draw', function (data) {
          if (data.type === 'point') {
            if (data.meta.lesson_id === lessonId) {
              data.group.elem('circle', {
                cx: data.x,
                cy: data.y,
                r: 6,
                style: 'fill: #4CAF50'
              });
            }
            data.element._node.setAttribute('style', 'cursor: pointer');
            data.element._node.addEventListener("click", function() {window.location = (data.meta.lesson_url + window.location.search);});
          }
        });
      }
    ]
  });

}

function displayAveragesGraph(containerId, studentId, data) {
  let responsiveOptions = [
    ['print', {
      width: 580,
      height: 300,
      stretch: true,
      axisX:{
        divisor: 5
      }
    }]
  ];

  new Chartist.Line(containerId, {
    series: [
      {
        name: 'Grades',
        data: data.map(function(e) {
          return {
            x: new Date(e.lesson_date).getTime(), // Convert to timestamp in milliseconds
            y: e.average_mark,
            meta: {
              student_id: studentId
            }
          };
        })
      }
    ]
  }, {
    axisX: {
      type: Chartist.FixedScaleAxis,
      divisor: 10,
      labelInterpolationFnc: function (value) {
        return new Date(value).toLocaleDateString('en-US'); // Convert timestamp back to date
      }
    },
    axisY: {
      onlyInteger: true,
      low: 1,
      high: 7
    },
    plugins: [
      function(chart) {
        chart.on('draw', function (data) {
          if (data.type === 'point') {
            if (data.meta.student_id === studentId) {
              data.group.elem('circle', {
                cx: data.x,
                cy: data.y,
                r: 1,
                style: 'fill: #9C27B0; stroke: #9C27B0;',
              });
            }
          }
        });
      }
    ]
  }, responsiveOptions);
}

function displayPercentagesGraph(containerId, data) {
  let firstLesson = new Date(data[0].lesson_date)
  let dayBeforeFirstLesson = new Date(firstLesson.getTime())
  dayBeforeFirstLesson.setDate(firstLesson.getDate() - 1)

  let options = [
      ['', {
        height: 500
      }],

    ['print', {
      width: 1200,
      height: 300,
      stretch: true,
      axisX: {
        divisor: 10
      }
    }]
  ];

  new Chartist.Bar(containerId, {
    series: [
      {
        name: 'Attendances',
        data: data.map(function(e) {
          return {
            x: new Date(e.lesson_date).getTime(), // Convert to timestamp in milliseconds
            y: e.attendance,
          };
        })
      }
    ]
  }, {
    fullWidth: true,
    chartPadding: 20,
    axisX: {
      type: Chartist.FixedScaleAxis,
      low: dayBeforeFirstLesson.getTime(),
      divisor: 20,
      labelInterpolationFnc: function (value) {
        return new Date(value).toLocaleDateString('en-US'); // Convert timestamp back to date
      }
    },
    axisY: {
      labelInterpolationFnc: function (value) {
        return `${value}%`  // Convert to string with %
      }
    }
  }, options);
}


function displayTimelineGraph(containerId, data){
 let inMultipleYears = data.some(d => new Date(d.active_since).getFullYear() !== new Date(Date.now()).getFullYear()
      || new Date(d.inactive_since).getFullYear()  !== new Date(Date.now()).getFullYear())

 let timeline_pills = data.map( function(d, i) {
    return {
        id: d.student_id,
        name: d.student_name,
        start: new Date(d.active_since),
        end: new Date(d.inactive_since),
        progress: 0,
        dependencies: d.dependent_on,
        custom_class: 'timeline-pill'
      }
    }
  )

  let dataToRender = [...timeline_pills, {
    id: 'Today',
    name: 'Today',
    start: new Date(),
    end: new Date(),
    progress: 0,
    custom_class: 'timeline-pill today'
  }]


  let container = document.getElementById(containerId.substring(1))
  // Height is set in accordance with the options for the chart below plus some extra spacing
  // items * (padding + bar_height + one extra row for today's date) + header_height + 10
  container.style.minHeight = `${(dataToRender.length * 25 + 50)}px`

  new Gantt(containerId, dataToRender, {
     date_format: 'YYYY-MM-DD',
     view_mode: inMultipleYears ? 'Year' : 'Month',
     header_height: 40,
     padding: 12,
     bar_height: 12,
     bar_corner_radius: 3,
     arrow_curve: 10,
     popup: null,
     gantt_start: data[0].first_lesson,
     gantt_end: data[0].last_lesson
  });
}