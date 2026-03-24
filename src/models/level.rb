class Level
  attr_reader :mode, :difficulty, :index, :total, :payload

  def initialize(mode:, difficulty:, index:, total:, payload: {})
    @mode = mode
    @difficulty = difficulty
    @index = index
    @total = total
    @payload = payload
  end
end

