class Randomizer
  def initialize(seed: nil)
    @rng = seed.nil? ? Random.new : Random.new(seed)
  end

  def choice(array)
    return nil if array.nil? || array.empty?

    array[@rng.rand(array.length)]
  end

  def shuffle(array)
    return [] if array.nil?

    array.shuffle(random: @rng)
  end

  def sample_without_replacement(array, count)
    return [] if array.nil?
    count = 0 if count.negative?
    count = array.length if count > array.length

    shuffle(array).take(count)
  end
end

