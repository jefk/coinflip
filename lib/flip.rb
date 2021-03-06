class Flip
  def self.get(id)
    data = self.redis.get(id)
    return nil if data.nil?

    data = Yajl.load(data)
    seconds_left = data['time_of_flip'] - Time.now.to_i
    if seconds_left > 0
      {seconds_left: seconds_left, result: nil}
    else
      {seconds_left: 0, result: data['result']}
    end
  end

  def self.exist?(id)
    self.redis.exists(id)
  end

  def self.create(seconds)
    id = SecureRandom.hex 2
    flip_data = Yajl.dump(
      time_of_flip: (Time.now + seconds.to_i).to_i,
      result: rand(2) == 0 ? 'heads' : 'tails',
    )

    self.redis.set(id, flip_data)

    id
  end

  private

  def self.redis
    if ENV['REDISTOGO_URL'].nil?
      @@redis ||= Redis.new
    else
      uri = URI.parse(ENV["REDISTOGO_URL"])
      @@redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end
  end
end
