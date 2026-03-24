require_relative "base_scene"
require_relative "../config/game_config"
require_relative "../config/ui_theme"
require_relative "../utils/text_align"
require_relative "../ui/panel"

class ModeSelectScene < BaseScene
  def enter(_args = {})
    super

    cx = GameConfig::WINDOW_WIDTH / 2.0
    add_element(
      Panel.new(
        x: cx - 360, y: 178,
        width: 720, height: 100,
        radius: 34,
        fill_color: UiTheme::PANEL_FILL,
        border_color: UiTheme::PANEL_BORDER,
        border_width: 5,
        opacity: 0.68,
        z: 18
      )
    )
    add_element(
      Panel.new(
        x: cx - 290, y: 292,
        width: 580, height: 300,
        radius: 30,
        fill_color: UiTheme::PANEL_FILL,
        border_color: UiTheme::PANEL_BORDER,
        border_width: 5,
        opacity: 0.48,
        z: 9
      )
    )

    @title = Ruby2D::Text.new(
      Texts::ALL[:mode_title],
      x: 0,
      y: 210,
      size: 46,
      color: UiTheme::TITLE_GREEN,
      z: 20
    )
    TextAlign.center_horizontally(@title, GameConfig::WINDOW_WIDTH)
    add_element(@title)

    @btn_find = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 310,
      width: 520,
      height: 78,
      text: Texts::ALL[:mode_find_color],
      font_size: 30,
      on_click: -> { start_mode(:find_color) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )
    @btn_match = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 402,
      width: 520,
      height: 78,
      text: Texts::ALL[:mode_match_pairs],
      font_size: 28,
      on_click: -> { start_mode(:match_pairs) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )
    @btn_ton = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 494,
      width: 520,
      height: 78,
      text: Texts::ALL[:mode_ton_catch],
      font_size: 28,
      on_click: -> { show_ton_toast },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: "#F3F3F3",
      border_color: "#9E9E9E",
      text_color: "#666666"
    )

    @buttons.concat([@btn_find, @btn_match, @btn_ton])
    add_element(@btn_find)
    add_element(@btn_match)
    add_element(@btn_ton)
  end

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?

    click_first_matching_button(event.x, event.y)
  end

  private

  def start_mode(mode)
    @state_machine.go_to(:difficulty_select, args: { mode: mode }, push: true)
  end

  def show_ton_toast
    @game.audio_manager.play_wrong

    return if defined?(@toast) && @toast

    @toast = Ruby2D::Text.new(
      Texts::ALL[:ton_catch_unavailable],
      x: 0,
      y: 595,
      size: 30,
      color: "#2E7D32",
      z: 80
    )
    TextAlign.center_horizontally(@toast, GameConfig::WINDOW_WIDTH)
    add_element(@toast)

    @toast.opacity = 0.0 if @toast.respond_to?(:opacity=)
    @animation_helper.tween_opacity(
      objects: [@toast],
      from: 0.0,
      to: 1.0,
      duration_ms: 220
    )
    @animation_helper.tween_opacity(
      objects: [@toast],
      from: 1.0,
      to: 0.0,
      duration_ms: 480,
      remove_on_finish: true
    )
  end
end

