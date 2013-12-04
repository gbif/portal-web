function parseRSS(url, callback) {
  $.ajax({
    url: document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&callback=?&q=' + encodeURIComponent(url),
    dataType: 'json',
    success: function(data) {
      callback(data.responseData.feed);
    }
  });
}

function parseGbifNews(callback) {
  parseRSS('http://imsgbif.gbif.org/rss.xml', callback);
}

function parseDevNews(callback) {
  parseRSS('http://gbif.blogspot.com/feeds/posts/default', callback);
}

