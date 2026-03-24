require_relative "base_scene"
require_relative "../config/game_config"
require_relative "../config/ui_theme"
require_relative "../config/visual_theme"
require_relative "../utils/text_align"
require_relative "../utils/color_utils"
require_relative "../ui/panel"

class MenuScene < BaseScene
  def enter(_args = {})
    super

    cx = GameConfig::WINDOW_WIDTH / 2.0
    @title_rail = Panel.new(
      x: cx - 360, y: 178,
      width: 720, height: 108,
      radius: 36,
      fill_color: UiTheme::PANEL_FILL,
      border_color: UiTheme::PANEL_BORDER,
      border_width: 5,
      opacity: 0.72,
      z: 18
    )
    add_element(@title_rail)

    @button_rail = Panel.new(
      x: cx - 290, y: 292,
      width: 580, height: 418,
      radius: 32,
      fill_color: UiTheme::PANEL_FILL,
      border_color: UiTheme::PANEL_BORDER,
      border_width: 5,
      opacity: 0.5,
      z: 9
    )
    add_element(@button_rail)

    [-140, 0, 140].each do |dx|
      add_element(
        Circle.new(
          x: cx + dx, y: 268, radius: 5,
          color: UiTheme::ACCENT_GOLD, opacity: 0.85, z: 24
        )
      )
    end

    @title = Ruby2D::Text.new(
      Texts::ALL[:app_name],
      x: 0,
      y: 200,
      size: 66,
      color: UiTheme::TITLE_GREEN,
      z: 25
    )
    TextAlign.center_horizontally(@title, GameConfig::WINDOW_WIDTH)
    @title_y_base = @title.y.to_f
    @title_phase = rand * Math::PI * 2
    add_element(@title)

    @btn_start = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 320,
      width: 520,
      height: GameConfig::MENU_BUTTON_HEIGHT,
      text: Texts::ALL[:menu_start],
      font_size: 28,
      on_click: -> { handle_start },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )
    @btn_help = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 408,
      width: 520,
      height: GameConfig::MENU_BUTTON_HEIGHT,
      text: Texts::ALL[:menu_howto],
      font_size: 26,
      on_click: -> { @state_machine.go_to(:help, args: {}, push: true) },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @btn_sound = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 488,
      width: 520,
      height: GameConfig::MENU_BUTTON_HEIGHT,
      text: sound_button_text,
      font_size: 26,
      on_click: -> { toggle_sound },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @btn_theme = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 568,
      width: 520,
      height: 56,
      text: theme_button_text,
      font_size: 22,
      on_click: -> { cycle_theme },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: UiTheme::BTN_FILL,
      border_color: UiTheme::BTN_BORDER
    )

    @btn_exit = Button.new(
      x: GameConfig::WINDOW_WIDTH / 2.0 - 260,
      y: 640,
      width: 520,
      height: 52,
      text: Texts::ALL[:menu_exit],
      font_size: 24,
      on_click: -> { quit_game },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: ColorUtils.lighten(UiTheme::BTN_FILL, 0.03),
      border_color: UiTheme::BTN_BORDER
    )

    @buttons.concat([@btn_start, @btn_help, @btn_sound, @btn_theme, @btn_exit])
    add_element(@btn_start)
    add_element(@btn_help)
    add_element(@btn_sound)
    add_element(@btn_theme)
    add_element(@btn_exit)
  end

  def update(dt)
    super
    return unless @title && @title_y_base

    @title_phase = (@title_phase || 0.0) + dt.to_f * GameConfig::MENU_TITLE_FLOAT_SPEED
    @title.y = @title_y_base + GameConfig::MENU_TITLE_FLOAT_AMPLITUDE * Math.sin(@title_phase)
  end

  def handle_back_click
    quit_game
  end

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?

    click_first_matching_button(event.x, event.y)
  end

  private

  def sound_button_text
    @game.audio_manager.sound_enabled? ? Texts::ALL[:sound_on] : Texts::ALL[:sound_off]
  end

  def theme_button_text
    k = VisualTheme.normalize(@game.player_progress.theme_key)
    sym = :"theme_name_#{k}"
    name = Texts::ALL[sym] || Texts::ALL[:theme_name_garden]
    format(Texts::ALL[:theme_menu_label], name: name)
  end

  def cycle_theme
    ord = VisualTheme::KEYS
    cur = VisualTheme.normalize(@game.player_progress.theme_key)
    idx = ord.index(cur) || 0
    @game.player_progress.theme_key = ord[(idx + 1) % ord.size]
    @game.save_service.save_progress(@game.player_progress)
    @game.refresh_window_theme!
    @state_machine.go_to(:menu, args: {}, push: false)
  end

  def toggle_sound
    @game.audio_manager.toggle_sound
    @game.player_progress.sound_enabled = @game.audio_manager.sound_enabled?
    @game.save_service.save_progress(@game.player_progress)

    @btn_sound.set_text(sound_button_text)
  end

  def handle_start
    @state_machine.go_to(:mode_select, args: {}, push: true)
  end

  def quit_game
    @game.close
  end
end

