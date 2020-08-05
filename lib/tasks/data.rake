namespace :data do

  # rake data:generate[1,10]
  task :generate, [:categories_num, :reviews_num] => [:environment] do |task, args|
    args.with_defaults(categories_num: 3, reviews_num: 1000)

    Rails.logger.silence do
      Data::Generator.generate_reviews(
        categories_num: args[:categories_num].to_i,
        reviews_num: args[:reviews_num].to_i
      )
    end
  end

  # rake data:benchmark
  task benchmark: :environment do |task, args|
    Rails.logger.silence do
      Data::Benchmarker.benchmark_multiple_queries
    end
  end

  # rake data:generate_and_benchmark
  task generate_and_benchmark: :environment do |task, args|
    Rails.logger.silence do
      Data::Benchmarker.run
    end
  end

end
