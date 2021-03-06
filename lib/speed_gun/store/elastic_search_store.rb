require 'speed_gun/store'

class SpeedGun::Store::ElasticSearchStore < SpeedGun::Store
  DEFAULT_INDEX = 'speed_gun'

  def initialize(options = {})
    @index = options[:index] || DEFAULT_INDEX
    @async = options.fetch(:async, true)
    @client = options[:client] || default_clinet(options)
  end

  def save(object)
    @async ? save_with_async(object) : save_without_async(object)
  end

  def load(klass, id)
    hit = @client.search(
      index: @index,
      body: {
        query: {
          match: {
            "_id" => id,
            "_type" => underscore(klass.name)
          }
        }
      }
    )['hits']['hits'].first['_source']

    klass.from_hash(id, hit)
  end

  private

  def save_with_async(object)
    Thread.new(object) { |object| save_without_async(object) }
  end

  def save_without_async(object)
    @client.index(
      index: @index,
      type: underscore(object.class.name),
      id: object.id,
      body: object.to_hash.merge(
        '@timestamp' => Time.now
      )
    )
  end

  def index(klass)
    [@prefix, underscore(klass.name)].join('-')
  end

  def underscore(name)
    name = name
    name.sub!(/^[A-Z]/) { |c| c.downcase }
    name.gsub!(/[A-Z]/) { |c| "_#{c.downcase}" }
    name.gsub!('::', '')
  end

  def default_clinet(options)
    require 'elasticsearch' unless defined?(Elasticsearch)
    Elasticsearch::Client.new(options)
  end
end
