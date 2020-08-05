require 'benchmark'

class Data::Benchmarker

  def self.run
    data_sizes = [
      {categoies_count: 1, reviews_count: 10},
      {categoies_count: 3, reviews_count: 10_000},
      {categoies_count: 5, reviews_count: 100_000},
      {categoies_count: 8, reviews_count: 1_000_000},
      {categoies_count: 10, reviews_count: 10_000_000}
    ]

    log_progress("Benchmarking started #{Time.now} for these data sizes #{data_sizes}")

    category_ids_filter = []
    theme_ids_filter = []
    data_sizes.each do |data_size|
      # generate the data first
      log_progress("Generating data for #{data_size}")
      Data::Generator.generate_reviews(
        categories_num: data_size[:categoies_count].to_i,
        reviews_num: data_size[:reviews_count].to_i
      )

      # then try the same query against both database and index, and log times
      category_ids = Category.last(3).ids
      theme_ids = category_ids.map { |c_id| Theme.where(category_id: cid).first.id }
      category_ids_filter << category_ids
      theme_ids_filter << theme_ids
      sample_query = {
        comment_filter: 'now',
        category_ids_filter: category_ids_filter.flatten,
        theme_ids_filter: theme_ids_filter.flatten
      }
      benchmark_sample_query(sample_query: sample_query, data_size: data_size)
    end
  end

  def self.benchmark_sample_query(sample_query: nil, data_size: nil, log: true)
    data_size ||= {categories_num: Category.count, reviews_num: Review.count}
    if sample_query.blank?
      category_ids = []
      3.times {|_i| category_ids << sample_record(Category).id }
      theme_ids = category_ids.map { |c_id| Theme.where(category_id: c_id).first.id }

      sample_query = {
        comment_filter: sample_record(Review).comment.split.sample,
        category_ids_filter: category_ids,
        theme_ids_filter: theme_ids
      }
    end

    log_progress("Benchmarking this query #{sample_query} for #{data_size}, database first, then the index") if log
    benchmark_info = Benchmark.bm do |x|
      x.report('Database:') { SearchReviewsDatabaseService.new(sample_query).call.all }
      x.report('Index   :') { SearchReviewsIndexService.new(sample_query).call }
    end;
    log_benchmark_info(benchmark_info) if log

    benchmark_info
  end

  def self.benchmark_multiple_queries(run_times: 100)
    database_time = 0
    index_time = 0
    run_times.times do |_i|
      benchmark_info = benchmark_sample_query(log: false)
      database_time += benchmark_info.first.real
      index_time += benchmark_info.last.real
    end

    data_size = {categories_num: Category.count, reviews_num: Review.count}
    text = "\n\r\n\r===========\n\r"
    text += "Benchmarking #{run_times} sample queries against data size of #{data_size}, yielded these results:\n\r"
    text += "Total time spent in database #{database_time}\n\r"
    text += "                Vs. in index #{index_time}\n\r"
    ratio = sprintf('%.2f', database_time/index_time)
    text += "So total time in database was #{ratio}x in index!\n\r"
    text += '=================='

    log_progress(text)
    {database_time: database_time, index_time: index_time}
  end

  def self.log_benchmark_info(benchmark_info)
    text = "===========\n\r"
    text += "Database: #{benchmark_info.first.real}\n\r"
    text += "Index   : #{benchmark_info.last.real}\n\r"
    text += '=================='
    log_progress(text)
  end

  def self.log_progress(text)
    text = "#{text}\n\r"
    puts text
    file_path = File.join(Rails.root, 'public', 'benchmark_result.txt')
    File.write(file_path, text, mode: 'a')
  end

  # returns a random record from the given scope
  def self.sample_record(scope)
    # can use order by rand also
    offset = rand(scope.count)
    scope.offset(offset).first
  end

end
