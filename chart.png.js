$(function () {
  $('#container').highcharts({
      title: {
        text: "Top five assignees in 'Autonomous vehicles'"
      },
      yAxis: {
        title: {
          text: "DB patents"
        }
      },
      credits: {
        enabled: false
      },
      exporting: {
        enabled: false
      },
      plotOptions: {
        series: {
          turboThreshold: 0,
          marker: {
            enabled: false
          }
        },
        treemap: {
          layoutAlgorithm: "squarified"
        },
        bubble: {
          minSize: 5,
          maxSize: 25
        }
      },
      annotationsOptions: {
        enabledButtons: false
      },
      tooltip: {
        delayForDisplay: 10
      },
      series: [
        {
          name: "GM Global Technology Operations, Inc.",
          type: "line",
          data: [
            {
              assignee_organization: "GM Global Technology Operations, Inc.",
              app_yr: 2010,
              n: 3,
              x: 2010,
              y: 3
            },
            {
              assignee_organization: "GM Global Technology Operations, Inc.",
              app_yr: 2013,
              n: 1,
              x: 2013,
              y: 1
            },
            {
              assignee_organization: "GM Global Technology Operations, Inc.",
              app_yr: 2014,
              n: 1,
              x: 2014,
              y: 1
            }
          ]
        },
        {
          name: "Google Inc.",
          type: "line",
          data: [
            {
              assignee_organization: "Google Inc.",
              app_yr: 2010,
              n: 1,
              x: 2010,
              y: 1
            },
            {
              assignee_organization: "Google Inc.",
              app_yr: 2011,
              n: 6,
              x: 2011,
              y: 6
            },
            {
              assignee_organization: "Google Inc.",
              app_yr: 2012,
              n: 11,
              x: 2012,
              y: 11
            },
            {
              assignee_organization: "Google Inc.",
              app_yr: 2013,
              n: 7,
              x: 2013,
              y: 7
            },
            {
              assignee_organization: "Google Inc.",
              app_yr: 2014,
              n: 14,
              x: 2014,
              y: 14
            },
            {
              assignee_organization: "Google Inc.",
              app_yr: 2015,
              n: 8,
              x: 2015,
              y: 8
            },
            {
              assignee_organization: "Google Inc.",
              app_yr: 2016,
              n: 1,
              x: 2016,
              y: 1
            }
          ]
        },
        {
          name: "Toyota Motor Engineering & Manufacturing North America, Inc.",
          type: "line",
          data: [
            {
              assignee_organization: "Toyota Motor Engineering & Manufacturing North America, Inc.",
              app_yr: 2014,
              n: 2,
              x: 2014,
              y: 2
            },
            {
              assignee_organization: "Toyota Motor Engineering & Manufacturing North America, Inc.",
              app_yr: 2015,
              n: 4,
              x: 2015,
              y: 4
            }
          ]
        },
        {
          name: "Waymo LLC",
          type: "line",
          data: [
            {
              assignee_organization: "Waymo LLC",
              app_yr: 2013,
              n: 1,
              x: 2013,
              y: 1
            },
            {
              assignee_organization: "Waymo LLC",
              app_yr: 2014,
              n: 2,
              x: 2014,
              y: 2
            },
            {
              assignee_organization: "Waymo LLC",
              app_yr: 2015,
              n: 1,
              x: 2015,
              y: 1
            },
            {
              assignee_organization: "Waymo LLC",
              app_yr: 2016,
              n: 2,
              x: 2016,
              y: 2
            }
          ]
        },
        {
          name: "Zoox, Inc.",
          type: "line",
          data: [
            {
              assignee_organization: "Zoox, Inc.",
              app_yr: 2015,
              n: 5,
              x: 2015,
              y: 5
            }
          ]
        }
      ],
      xAxis: {
        title: {
          text: "Application year"
        }
      },
      subtitle: {
        text: "Yearly patent applications over time"
      }
    }
  );
});
