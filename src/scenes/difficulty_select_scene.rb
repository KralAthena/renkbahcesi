require_relative "base_scene"
require_relative "../config/game_config"
require_relative "../config/ui_theme"
require_relative "../utils/text_align"
require_relative "../ui/panel"

class DifficultySelectScene < BaseScene
  def enter(args = {})
    super
    @mode = args[:mode]

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
      "#{Texts::ALL[:difficulty_title]}",
      x: 0,
      y: 210,
      size: 44,
      color: UiTheme::TITLE_GREEN,
      z: 20
    )
    TextAlign.center_horizontally(@title, GameConfig::WINDOW_WIDTH)
    add_element(@title)

    @btn_easy = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 310,
      width: 520,
      height: 78,
      text: Texts::ALL[:difficulty_easy],
      font_size: 30,
      on_click: -> { select_difficulty(:easy) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @btn_medium = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 402,
      width: 520,
      height: 78,
      text: Texts::ALL[:difficulty_medium],
      font_size: 30,
      on_click: -> { select_difficulty(:medium) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @btn_hard = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 494,
      width: 520,
      height: 78,
      text: Texts::ALL[:difficulty_hard],
      font_size: 30,
      on_click: -> { select_difficulty(:hard) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @buttons.concat([@btn_easy, @btn_medium, @btn_hard])
    add_element(@btn_easy)
    add_element(@btn_medium)
    add_element(@btn_hard)
  end

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?

    click_first_matching_button(event.x, event.y)
  end

  private

  def select_difficulty(difficulty)
    @game.game_session_service.start_session(mode: @mode, difficulty: difficulty)

    next_scene =
      case @mode
      when :find_color
        :game_find_color
      when :match_pairs
        :game_match_pairs
      when :ton_catch
        :game_find_color
      else
        :menu
      end

    @state_machine.go_to(next_scene, args: {}, push: true)
  end
end

