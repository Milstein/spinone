/*global d3, barViz, donutViz */

var endDate = new Date(),
    startDate = d3.time.day.offset(endDate, -29),
    endTime = endDate.setHours(23),
    startTime = d3.time.hour.offset(endTime, -23),
    colors = d3.scale.ordinal().range(["#2582d5","#145996","#e2e6e7"]);

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var query = encodeURI("/status");
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Accept", "application/json")
    .header("Authorization", "Token token=" + api_key)
    .get(function(error, json) {
      if (error) { return console.warn(error); }
      var data = json.data;

      // aggregate status by day
      var day_data = data.filter(function(status) {
        return Date.parse(status.attributes.timestamp) >= startDate;
      });
      var by_day = d3.nest()
        .key(function(d) { return d.attributes.timestamp.substr(0,10); })
        .rollup(function(leaves) {
          return { "db_size": d3.max(leaves, function(d) { return d.attributes["db-size"];}),
                  };})
        .entries(day_data);

      var members = d3.entries(data[0].attributes["members-count"]);
      var members_title = d3.sum(members, function(g) { return g.value; });

      barViz(by_day, "#chart_db_size", "db_size", "days");
  });
}
