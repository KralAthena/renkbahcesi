require_relative "base_scene"
require_relative "../config/game_config"
require_relative "../config/ui_theme"
require_relative "../utils/text_align"
require_relative "../ui/panel"

class ResultScene < BaseScene
  def enter(_args = {})
    super

    @session = @game.game_session_service

    cx = GameConfig::WINDOW_WIDTH / 2.0
    @backdrop = Panel.new(
      x: cx - 520, y: 148,
      width: 1040, height: 548,
      radius: 36,
      fill_color: UiTheme::PANEL_FILL,
      border_color: UiTheme::PANEL_BORDER,
      border_width: 6,
      opacity: 0.62,
      z: 9
    )
    add_element(@backdrop)

    [-52, 0, 52].each do |dx|
      add_element(
        Circle.new(
          x: cx + dx, y: 178, radius: 7,
          color: UiTheme::ACCENT_GOLD, opacity: 0.9, z: 24
        )
      )
    end

    @title = Ruby2D::Text.new(
      Texts::ALL[:result_title],
      x: 0,
      y: 210,
      size: 52,
      color: UiTheme::TITLE_GREEN,
      z: 25
    )
    TextAlign.center_horizontally(@title, GameConfig::WINDOW_WIDTH)
    add_element(@title)

    score = @session.score.to_i
    stars = @session.stars.to_i

    @score_text = Ruby2D::Text.new(
      "#{Texts::ALL[:result_score]}: #{score}",
      x: 0,
      y: 330,
      size: 40,
      color: "#047857",
      z: 25
    )
    TextAlign.center_horizontally(@score_text, GameConfig::WINDOW_WIDTH)
    add_element(@score_text)

    star_str = "★" * stars + "☆" * (3 - stars)
    @stars_text = Ruby2D::Text.new(
      "#{Texts::ALL[:result_stars]}: #{stars}/3  #{star_str}",
      x: 0,
      y: 420,
      size: 30,
      color: "#0D9488",
      z: 25
    )
    TextAlign.center_horizontally(@stars_text, GameConfig::WINDOW_WIDTH)
    add_element(@stars_text)

    @hint = Ruby2D::Text.new(
      Texts::ALL[:result_play_again_hint],
      x: 0,
      y: 490,
      size: 24,
      color: "#145A14",
      z: 25
    )
    TextAlign.center_horizontally(@hint, GameConfig::WINDOW_WIDTH)
    add_element(@hint)

    @btn_restart = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 540,
      width: 520,
      height: 78,
      text: Texts::ALL[:result_restart],
      font_size: 30,
      on_click: -> { restart },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @btn_menu = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 630,
      width: 520,
      height: 56,
      text: Texts::ALL[:result_menu],
      font_size: 26,
      on_click: -> { @state_machine.go_to(:menu, args: {}, push: false) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @buttons.concat([@btn_restart, @btn_menu])
    add_element(@btn_restart)
    add_element(@btn_menu)
  end

  def handle_back_click
    @state_machine.go_to(:menu, args: {}, push: false)
  end

  def restart
    @session.start_session(mode: @session.mode, difficulty: @session.difficulty)

    next_scene =
      case @session.mode.to_sym
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

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?

    click_first_matching_button(event.x, event.y)
  end
end

