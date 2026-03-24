class Timer
  def initialize
    @start_time_ms = nil
    @accumulated_ms = 0
    @running = false
  end

  def start
    return if @running

    @start_time_ms = now_ms
    @running = true
  end

  def stop
    return unless @running

    @accumulated_ms += now_ms - @start_time_ms
    @start_time_ms = nil
    @running = false
  end

  def reset
    @start_time_ms = nil
    @accumulated_ms = 0
    @running = false
  end

  def running?
    @running
  end

  def elapsed_ms
    return @accumulated_ms unless @running

    @accumulated_ms + (now_ms - @start_time_ms)
  end

  private

  def now_ms
    (Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)).to_f
  end
end

