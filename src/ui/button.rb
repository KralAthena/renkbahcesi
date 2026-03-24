require_relative "panel"
require_relative "label"
require_relative "../core/animation_helper"
require_relative "../utils/color_utils"
require_relative "../utils/text_align"

class Button
  attr_reader :x, :y, :width, :height

  def initialize(
    x:,
    y:,
    width:,
    height:,
    text:,
    enabled: true,
    font_size: 28,
    on_click: nil,
    fill_color: "#F9FFFA",
    border_color: "#3A7A3A",
    border_width: 6,
    text_color: "#155B15",
    hover_opacity: 0.18,
    animation_helper: nil,
    audio_manager: nil
  )
    @x = x.to_f
    @y = y.to_f
    @width = width.to_f
    @height = height.to_f

    @enabled = enabled
    @on_click = on_click
    @audio_manager = audio_manager
    @animation_helper = animation_helper

    panel_radius = [height / 2.0, GameConfig::PANEL_RADIUS].min

    @shadow_panel = Panel.new(
      x: @x + 3, y: @y + 5,
      width: @width, height: @height,
      radius: panel_radius,
      fill_color: "#061208",
      border_color: "#061208",
      border_width: 2,
      opacity: 0.26,
      z: 28
    )

    @base_panel = Panel.new(
      x: @x, y: @y,
      width: @width, height: @height,
      radius: panel_radius,
      fill_color: fill_color,
      border_color: border_color,
      border_width: border_width,
      opacity: 1.0,
      z: 30
    )

    hover_fill = ColorUtils.lighten(fill_color, 0.14)
    hover_border = border_color
    @hover_panel = Panel.new(
      x: @x, y: @y,
      width: @width, height: @height,
      radius: panel_radius,
      fill_color: hover_fill,
      border_color: hover_border,
      border_width: border_width,
      opacity: 0.0,
      z: 31
    )
    @hover_target_opacity = hover_opacity.to_f

    @label = Label.new(
      text: text,
      x: 0,
      y: 0,
      size: font_size,
      color: text_color,
      z: 40
    )
    align_label!
  end

  def update_hover(mouse_x:, mouse_y:)
    return unless @enabled

    hovered = contains_point?(mouse_x, mouse_y)
    return if hovered == @hovered

    @hovered = hovered

    if @animation_helper
      if hovered
        first = @hover_panel.primitives.first
        current_opacity = first && first.respond_to?(:opacity) ? first.opacity : 0.0
        @animation_helper.tween_opacity(
          objects: @hover_panel.primitives,
          from: current_opacity,
          to: @hover_target_opacity,
          duration_ms: 140,
          easing: :ease_out_cubic
        )
      else
        @animation_helper.tween_opacity(
          objects: @hover_panel.primitives,
          from: @hover_target_opacity,
          to: 0.0,
          duration_ms: 120,
          easing: :ease_out_cubic
        )
      end
    else
      @hover_panel.opacity = hovered ? @hover_target_opacity : 0.0
    end
  end

  def contains_point?(px, py)
    px >= @x && px <= (@x + @width) && py >= @y && py <= (@y + @height)
  end

  def click!(px, py)
    return unless @enabled
    return unless contains_point?(px, py)

    @audio_manager&.play_button
    if @animation_helper
      @animation_helper.flash_press_primitives(
        primitives: @shadow_panel.primitives + @base_panel.primitives + @hover_panel.primitives
      )
    end
    @on_click&.call if @on_click
  end

  def set_text(new_text)
    return unless @label

    @label.text = new_text.to_s if @label.respond_to?(:text=)
    align_label!
  end

  def set_enabled(enabled)
    @enabled = !!enabled
  end

  def remove
    @shadow_panel.remove
    @base_panel.remove
    @hover_panel.remove
    @label.remove
  end

  def align_label!
    return unless @label&.text_obj

    TextAlign.center_in_rect(@label.text_obj, @x, @y, @width, @height)
  end
end

