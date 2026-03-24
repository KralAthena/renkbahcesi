require_relative "base_scene"
require_relative "../config/ui_theme"
require_relative "../utils/text_align"
require_relative "../ui/panel"

class HelpScene < BaseScene
  def enter(_args = {})
    super

    @panel = Panel.new(
      x: 140, y: 200,
      width: 1000, height: 460,
      radius: 28,
      fill_color: UiTheme::PANEL_FILL,
      border_color: UiTheme::PANEL_BORDER,
      border_width: 6,
      opacity: 0.88,
      z: 10
    )
    add_element(@panel)

    @title = Ruby2D::Text.new(
      Texts::ALL[:help_title],
      x: 0,
      y: 245,
      size: 46,
      color: UiTheme::TITLE_GREEN,
      z: 20
    )
    TextAlign.center_horizontally(@title, GameConfig::WINDOW_WIDTH)
    add_element(@title)

    lines = [
      Texts::ALL[:help_line_1],
      Texts::ALL[:help_line_2],
      Texts::ALL[:help_line_3],
      Texts::ALL[:help_line_4],
      Texts::ALL[:help_line_5]
    ]

    lines.each_with_index do |line, i|
      t = Ruby2D::Text.new(
        line,
        x: 0,
        y: 300 + i * 58,
        size: i == 4 ? 28 : 32,
        color: "#0F5132",
        z: 20
      )
      TextAlign.center_horizontally(t, GameConfig::WINDOW_WIDTH)
      add_element(t)
    end
  end

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?

    click_first_matching_button(event.x, event.y)
  end
end

