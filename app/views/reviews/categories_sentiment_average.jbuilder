json.averages @averages do |average|
  json.id average.first
  json.name Category.names[average.first]
  json.average_sentiment '%.2f' % average.last
  json.average_sentiment_as_percentage '%.2f' % ReviewTheme.senitment_as_percentage(average.last)
end
