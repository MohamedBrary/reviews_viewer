class FactoriesHelper

  # returns a random record from the given scope
  def self.sample_record(scope)
    # can use order by rand also
    offset = rand(scope.count)
    scope.offset(offset).first
  end

  # returns a random record from the given scope
  # if none available, creates a new record from respective factory
  def self.sample_record_or_generate(scope)
    sample_record(scope) || FactoryBot.create(scope.limit(1).klass.name.downcase.to_sym)
  end

  # returns a new record, copied from random record from the given scope
  # with optional params to override the original record attributes
  def self.create_sample_record_copy(scope, params={})
    original_attrs = sample_record(scope).attributes.except('id', 'created_at', 'updated_at')
    scope.create(original_attrs.merge(params))
  end

  def self.past_date(base: nil, days_range: 30)
    base ||= Time.zone.today
    base - (Random.rand(days_range) + 1).days
  end

  def self.random_interval(size)
    rand(1..size / 2)..rand((size / 2 + 1)..size)
  end

  # returns random subset of the array, with at least one element
  def self.random_sample_of(array)
    array.sample(rand(1..array.size))
  end
end
