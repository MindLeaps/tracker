//= require chartist

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
      width: 400,
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
  let options = [
      ['', {
        height: 500
      }],

    ['print', {
      width: 960,
      height: 300,
      stretch: true
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
    axisX: {
      type: Chartist.FixedScaleAxis,
      divisor: 10,
      labelInterpolationFnc: function (value) {
        return new Date(value).toLocaleDateString('en-US'); // Convert timestamp back to date
      }
    },
    axisY: {
      low: 0,
      high: 100,
      labelInterpolationFnc: function (value) {
        return `${value}%`  // Convert to string with %
      }
    }
  }, options);
}


function displayTimelineGraph(containerId, data){
  let dataSets = [{
    name: 'Marko',
    data: [
      {x: new Date(Date.parse('2024-01-01')).getTime(), y: 123},
      {x: new Date(Date.parse('2024-05-01')).getTime(), y: 123},
      {x: null, y: 123},
      {x: new Date(Date.parse('2024-07-01')).getTime(), y: 123},
      {x: new Date(Date.parse('2024-11-01')).getTime(), y: 123}
    ]
  },
    {
      name: 'Someone else',
      data: [
        {x: new Date(Date.parse('2024-01-01')).getTime(), y: 124},
        {x: new Date(Date.parse('2024-05-01')).getTime(), y: 124},
        {x: null, y: 124},
        {x: new Date(Date.parse('2024-07-01')).getTime(), y: 124},
        {x: new Date(Date.parse('2024-11-01')).getTime(), y: 124}
      ]
    },
    {
      name: 'Another someone',
      data: [
        {x: new Date(Date.parse('2023-01-01')).getTime(), y: 125},
        {x: new Date(Date.parse('2026-05-01')).getTime(), y: 125},
        {x: null, y: 125},
        {x: new Date(Date.parse('2028-07-01')).getTime(), y: 125},
        {x: new Date(Date.parse('2030-11-01')).getTime(), y: 125}
      ]
    }
  ]

  // new Highcharts.Chart('group_enrollments', {
  //   chart: {
  //     type: 'line'
  //   },
  //   title: {
  //     text: 'Student enrollments timeline'
  //   },
  //   yAxis:{
  //     tickInterval: 1,
  //     ticks: data.map(d => d.data[0].student_id),
  //     startOnTick: true,
  //     endOnTick: true,
  //     labels: {
  //       formatter: function() {
  //         return 'Student Id: ' + this.value
  //       }
  //     }
  //   },
  //   xAxis:{
  //     type: 'datetime',
  //     labels: {
  //       format: '{value:%Y-%m-%d}'
  //     }
  //   },
  //   series: data.map(function(e) {
  //       return {
  //         name: e.name,
  //         data: e.data.map(function (d) {
  //           return {
  //             x: new Date(Date.parse(d.date)).getTime(),
  //             y: d.student_id
  //           }
  //         })
  //       };
  //     })
  // });
  //


  let tasks = [
    {
      id: 'Task 1',
      name: 'Redesign website',
      start: '2016-12-28',
      end: '2016-12-31',
      progress: 20,
      dependencies: 'Task 2, Task 3',
      custom_class: 'bar-milestone' // optional
    }
  ]
   new Gantt(containerId, tasks, {});
}