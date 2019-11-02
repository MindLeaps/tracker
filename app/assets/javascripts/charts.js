//= require chartist

function displayLessonGraph(containerId, lessonUid, data) {
  new Chartist.Line(containerId, {
    series: [
      {
        data: data.map(function(e) {
          return {
            x: e.timestamp,
            y: e.average_mark,
            meta: {
              date: e.date,
              lesson_uid: e.lesson_uid,
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
    low: 1,
    high: 7,
    plugins: [
      function(chart) {
        chart.on('draw', function (data) {
          if (data.type === 'point') {
            if (data.meta.lesson_uid === lessonUid) {
              data.group.elem('circle', {
                cx: data.x,
                cy: data.y,
                r: 6,
                style: 'fill: #4CAF50'
              });
            }
            data.element._node.setAttribute('style', 'cursor: pointer');
            data.element._node.addEventListener("click", function() {Turbolinks.visit(data.meta.lesson_url);});
          }
        });
      }
    ]
  });

}
