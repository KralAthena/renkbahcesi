class InputHandler
  def initialize
    @locked_until_ms = 0
  end

  def locked?
    now_ms < @locked_until_ms
  end

  def lock_for(duration_ms)
    duration_ms = 0 if duration_ms.negative?
    @locked_until_ms = [@locked_until_ms, now_ms].max + duration_ms
  end

  def accept_click?
    !locked?
  end

  private

  def now_ms
    Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond).to_f
  end
end

