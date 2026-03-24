# frozen_string_literal: true

require_relative "base_scene"
require_relative "../core/timer"
require_relative "../config/game_config"
require_relative "../config/ui_theme"
require_relative "../utils/text_align"
require_relative "../ui/panel"

class SplashScene < BaseScene
  def enter(_args = {})
    super

    cx = GameConfig::WINDOW_WIDTH / 2.0
    cy = GameConfig::WINDOW_HEIGHT / 2.0

    # ── Large panel behind title ──
    @splash_panel = Panel.new(
      x: cx - 400, y: cy - 120,
      width: 800, height: 220,
      radius: 44,
      fill_color: "#F0FDF8",
      border_color: "#059669",
      border_width: 5,
      opacity: 0.68,
      z: 8
    )
    add_element(@splash_panel)

    # ── Decorative coloured dots (Nano palette preview) ──
    nano_colors = %w[#FF5252 #40C4FF #FFEB3B #69F0AE #FFAB40 #E040FB #FF4081]
    nano_colors.each_with_index do |col, i|
      angle = i * (2 * Math::PI / nano_colors.size) - Math::PI / 2.0
      dot_r  = 175
      dot_cx = cx + Math.cos(angle) * dot_r
      dot_cy = (cy - 50) + Math.sin(angle) * dot_r * 0.55
      @_dots ||= []
      d = Circle.new(x: dot_cx, y: dot_cy, radius: 18, color: col, z: 18, opacity: 0.88)
      @_dots << { obj: d, bx: dot_cx, by: dot_cy, phase: i * 0.9 }
      add_element(d)
    end

    # ── Title ──
    @title = Ruby2D::Text.new(
      Texts::ALL[:app_name],
      x: 0,
      y: cy - 95,
      size: 72,
      color: UiTheme::TITLE_GREEN,
      z: 20
    )
    TextAlign.center_horizontally(@title, GameConfig::WINDOW_WIDTH)
    @title_base_y = @title.y.to_f
    @title_phase  = 0.0
    add_element(@title)

    # ── Subtitle ──
    @subtitle = Ruby2D::Text.new(
      Texts::ALL[:splash_welcome],
      x: 0,
      y: cy + 14,
      size: 36,
      color: "#0D9488",
      z: 20
    )
    TextAlign.center_horizontally(@subtitle, GameConfig::WINDOW_WIDTH)
    add_element(@subtitle)

    @timer = Timer.new
    @timer.start
  end

  def update(dt)
    super

    # float title
    if @title && @title_base_y
      @title_phase = (@title_phase || 0.0) + dt.to_f * 1.8
      @title.y = @title_base_y + 8 * Math.sin(@title_phase)
    end

    # bob dots in circle
    @_dot_phase = (@_dot_phase || 0.0) + dt.to_f * 1.2
    @_dots&.each_with_index do |entry, i|
      o = entry[:obj]
      next unless o.respond_to?(:y=)
      o.y = entry[:by] + 6 * Math.sin(@_dot_phase + entry[:phase])
    end

    return unless @timer&.running?
    @state_machine.go_to(:menu, args: {}, push: false) if @timer.elapsed_ms >= GameConfig::SPLASH_MS
  end

  def handle_mouse_down(_event)
    # tap to skip
    @state_machine.go_to(:menu, args: {}, push: false)
  end
end
