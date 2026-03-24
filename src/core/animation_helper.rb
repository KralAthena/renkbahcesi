require_relative "../config/game_config"

class AnimationHelper
  Tween = Struct.new(:elapsed_ms, :duration_ms, :setter, :easing, :on_finish)

  def initialize
    @tweens = []
    @shakes = []
  end

  def update(dt_seconds)
    dt_seconds = 0.0 if dt_seconds.nil?
    dt_ms = dt_seconds * 1000.0

    @tweens.reject! do |tween|
      tween.elapsed_ms += dt_ms
      progress = tween.duration_ms.zero? ? 1.0 : (tween.elapsed_ms / tween.duration_ms.to_f)
      progress = 1.0 if progress > 1.0

      eased = tween.easing.call(progress)
      tween.setter.call(eased)

      if progress >= 1.0 && tween.on_finish
        tween.on_finish.call
      end

      progress >= 1.0
    end

    @shakes.reject! do |shake|
      shake[:elapsed_ms] += dt_ms
      progress = shake[:duration_ms].zero? ? 1.0 : (shake[:elapsed_ms] / shake[:duration_ms].to_f)
      progress = 1.0 if progress > 1.0

      damping = (1.0 - progress)
      phase = shake[:elapsed_ms] / shake[:period_ms].to_f
      amplitude = shake[:amplitude_px] * damping
      dx = Math.sin(phase * Math::PI * 2) * amplitude
      dy = Math.cos(phase * Math::PI * 2) * (amplitude * 0.35)

      shake[:items].each do |item|
        obj = item[:object]
        obj.x = item[:base_x] + dx if obj.respond_to?(:x=)
        obj.y = item[:base_y] + dy if obj.respond_to?(:y=)
      end

      progress >= 1.0
    end
  end

  def ease_out_cubic(progress)
    1 - (1 - progress) ** 3
  end

  def linear(progress)
    progress
  end

  def tween_opacity(objects:, from:, to:, duration_ms:, remove_on_finish: false, easing: :ease_out_cubic, on_finish: nil)
    return if objects.nil? || objects.empty?

    easing_fn = method(easing == :ease_out_cubic ? :ease_out_cubic : :linear)

    items = Array(objects)

    combined_finish = nil
    if remove_on_finish || on_finish
      combined_finish = lambda do
        on_finish&.call
        items.each { |obj| safe_remove(obj) } if remove_on_finish
      end
    end

    tween = Tween.new(0.0, duration_ms.to_f,
      lambda do |t|
        value = from + (to - from) * t
        items.each { |obj| set_opacity(obj, value) }
      end, easing_fn, combined_finish)
    @tweens << tween
  end

  def shake(objects:, amplitude_px:, duration_ms:, period_ms: 45)
    items = Array(objects).filter_map do |obj|
      next nil unless obj && obj.respond_to?(:x) && obj.respond_to?(:y)

      { object: obj, base_x: obj.x, base_y: obj.y }
    end

    return if items.empty?

    @shakes << {
      items: items,
      amplitude_px: amplitude_px.to_f,
      duration_ms: duration_ms.to_f,
      elapsed_ms: 0.0,
      period_ms: period_ms.to_f
    }
  end

  def spawn_glow_panel(x:, y:, width:, height:, radius:, fill_color:, border_color:, border_width:, z: 50, duration_ms:)
    require_relative "../ui/panel"

    panel = Panel.new(
      x: x, y: y,
      width: width, height: height,
      radius: radius,
      fill_color: fill_color,
      border_color: border_color,
      border_width: border_width,
      opacity: 0.0,
      z: z
    )

    in_ms = [(duration_ms * 0.45).to_i, 1].max
    out_ms = [(duration_ms * 0.55).to_i, 1].max

    tween_opacity(
      objects: panel.primitives,
      from: 0.0, to: 0.75,
      duration_ms: in_ms,
      on_finish: lambda {
        tween_opacity(
          objects: panel.primitives,
          from: 0.75, to: 0.0,
          duration_ms: out_ms,
          remove_on_finish: true
        )
      }
    )
    panel
  end

  def flash_press_primitives(primitives:, duration_ms: GameConfig::BUTTON_PRESS_FLASH_MS)
    prims = Array(primitives).compact
    return if prims.empty?

    d = [duration_ms.to_i, 40].max
    in_ms = [(d * 0.45).to_i, 1].max
    out_ms = [(d * 0.55).to_i, 1].max

    tween_opacity(
      objects: prims,
      from: 1.0, to: 0.78,
      duration_ms: in_ms,
      easing: :ease_out_cubic,
      on_finish: lambda {
        tween_opacity(
          objects: prims,
          from: 0.78, to: 1.0,
          duration_ms: out_ms,
          easing: :ease_out_cubic
        )
      }
    )
  end

  private

  def set_opacity(renderable, opacity)
    return unless renderable

    if renderable.respond_to?(:opacity=)
      renderable.opacity = opacity
      return
    end

    return unless renderable.respond_to?(:color)

    color = renderable.color
    return unless color && color.respond_to?(:opacity=)

    color.opacity = opacity
  end

  def safe_remove(renderable)
    renderable.remove if renderable.respond_to?(:remove)
  rescue StandardError
    nil
  end
end

