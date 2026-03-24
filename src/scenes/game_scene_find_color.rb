require_relative "base_scene"
require_relative "../ui/card_view"
require_relative "../ui/panel"
require_relative "../core/timer"
require_relative "../utils/text_align"

class GameSceneFindColor < BaseScene
  def back_button_config
    {
      text: Texts::ALL[:menu],
      x: GameConfig::MENU_BUTTON_X,
      y: GameConfig::MENU_BUTTON_Y,
      width: GameConfig::MENU_BUTTON_SIZE,
      height: GameConfig::MENU_BUTTON_SIZE
    }
  end

  def enter(_args = {})
    super

    @btn_sound = Button.new(
      x: GameConfig::SOUND_BUTTON_X,
      y: GameConfig::SOUND_BUTTON_Y,
      width: GameConfig::SOUND_BUTTON_SIZE,
      height: GameConfig::SOUND_BUTTON_SIZE,
      text: @game.audio_manager.sound_enabled? ? "Ses Açık" : "Ses Kapalı",
      font_size: 12,
      on_click: -> { toggle_sound },
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager,
      fill_color: @game.audio_manager.sound_enabled? ? "#E8FFF0" : "#F3F3F3",
      border_color: @game.audio_manager.sound_enabled? ? "#2E8B57" : "#9E9E9E",
      text_color: @game.audio_manager.sound_enabled? ? "#145A14" : "#666666"
    )
    @buttons << @btn_sound
    add_element(@btn_sound)

    @session = @game.game_session_service
    @round_timer = Timer.new
    @feedback_text = nil

    @task_text = Ruby2D::Text.new(
      "",
      x: 0,
      y: GameConfig::TASK_TEXT_Y,
      size: GameConfig::TASK_TEXT_SIZE,
      color: "#1B5E20",
      z: 30
    )
    add_element(@task_text)

    @options_cards = []
    @level_ui_elements = []

    build_score_panel
    load_current_level_ui
  end

  def handle_back_click
    @state_machine.go_to(:menu, args: {}, push: false)
  end

  def update(dt)
    super
    @options_cards&.each { |c| c.update(dt) if c.respond_to?(:update) }
    return unless @round_timer

    update_progress_ui
  end

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?
    return unless @session&.current_level

    px = event.x
    py = event.y

    return if click_first_matching_button(px, py)

    clicked_card = @options_cards.find { |c| c.contains_point?(px, py) }
    return unless clicked_card

    target_family_id = @session.current_level.payload[:target_family_id]
    correct = clicked_card.color_card.family_id == target_family_id

    clicked_card.set_selected

    if correct
      @game.audio_manager.play_correct
      clicked_card.set_correct

      @session.register_find_color_attempt(
        correct: true,
        click_duration_ms: @round_timer.elapsed_ms
      )

      @input_handler.lock_for(GameConfig::MATCH_POP_MS)

      continue = @session.complete_current_level!
      if continue
        load_current_level_ui
      else
        @state_machine.go_to(:result, args: {}, push: true)
      end
    else
      @game.audio_manager.play_wrong
      clicked_card.set_wrong

      @session.register_find_color_attempt(
        correct: false,
        click_duration_ms: @round_timer.elapsed_ms
      )

      show_feedback(Texts::ALL[:find_color_wrong])
      @input_handler.lock_for(GameConfig::INPUT_SPAM_LOCK_MS)
    end
  end

  private

  def toggle_sound
    @game.audio_manager.toggle_sound
    @game.player_progress.sound_enabled = @game.audio_manager.sound_enabled?
    @game.save_service.save_progress(@game.player_progress)

    @btn_sound.set_text(@game.audio_manager.sound_enabled? ? "Ses Açık" : "Ses Kapalı")
  end

  def build_score_panel
    @score_panel = Panel.new(
      x: GameConfig::SCORE_PANEL_X,
      y: GameConfig::SCORE_PANEL_Y,
      width: GameConfig::SCORE_PANEL_WIDTH,
      height: GameConfig::SCORE_PANEL_HEIGHT,
      radius: 22,
      fill_color: "#ECFDF5",
      border_color: "#059669",
      border_width: 5,
      opacity: 0.95,
      z: 25
    )
    add_element(@score_panel)

    @hud_text = Ruby2D::Text.new(
      "",
      x: 0,
      y: GameConfig::SCORE_PANEL_Y + 16,
      size: 24,
      color: "#145A14",
      z: 40
    )
    add_element(@hud_text)
  end

  def update_progress_ui
    streak = @session.current_streak.to_i
    streak_part = streak >= 1 ? "  ·  #{Texts::ALL[:streak_label]} #{streak}" : ""

    estimate_stars = @game.scoring_service.estimate_stars(
      stats: @session.stats,
      difficulty: @session.difficulty
    )

    total_seconds = @round_timer.elapsed_ms / 1000
    mm = (total_seconds / 60).to_i
    ss = (total_seconds % 60).to_i

    @hud_text.text = [
      "#{Texts::ALL[:result_score]}: #{@session.score}#{streak_part}",
      "Yıldız: #{estimate_stars}/3",
      format("Süre: %02d:%02d", mm, ss)
    ].join("     ")
    TextAlign.center_horizontally(@hud_text, GameConfig::WINDOW_WIDTH)
  end

  def show_feedback(text)
    @feedback_text&.remove if @feedback_text.respond_to?(:remove)

    @feedback_text = Ruby2D::Text.new(
      text,
      x: 0,
      y: 200,
      size: 34,
      color: "#1B5E20",
      z: 90
    )
    TextAlign.center_horizontally(@feedback_text, GameConfig::WINDOW_WIDTH)

    @feedback_text.opacity = 0.0 if @feedback_text.respond_to?(:opacity=)
    @animation_helper.tween_opacity(
      objects: [@feedback_text],
      from: 0.0,
      to: 1.0,
      duration_ms: 160
    )
    @animation_helper.tween_opacity(
      objects: [@feedback_text],
      from: 1.0,
      to: 0.0,
      duration_ms: 560,
      remove_on_finish: true
    )
  end

  def load_current_level_ui
    clear_level_ui

    level = @session.current_level
    payload = level.payload

    @round_timer.reset
    @round_timer.start

    @task_text.text = Texts.find_color_task(payload[:target_display_name])
    TextAlign.center_horizontally(@task_text, GameConfig::WINDOW_WIDTH)

    option_cards = payload[:options]
    options_count = option_cards.size
    cols = case options_count
           when 4 then 2
           when 6 then 3
           when 8 then 4
           else
             2
           end

    rows = 2
    total_width = cols * GameConfig::CARD_WIDTH + (cols - 1) * GameConfig::GRID_GAP_X
    start_x = (GameConfig::WINDOW_WIDTH - total_width) / 2.0

    @options_cards = []
    rows.times do |r|
      cols.times do |c|
        idx = r * cols + c
        card_def = option_cards[idx]
        next unless card_def

        x = start_x + c * (GameConfig::CARD_WIDTH + GameConfig::GRID_GAP_X)
        y = GameConfig::GRID_TOP_Y + r * (GameConfig::CARD_HEIGHT + GameConfig::GRID_GAP_Y)

        card_view = CardView.new(
          x: x,
          y: y,
          width: GameConfig::CARD_WIDTH,
          height: GameConfig::CARD_HEIGHT,
          color_card: card_def,
          on_click: nil,
          enabled: true,
          animation_helper: @animation_helper,
          face_down: false
        )

        @options_cards << card_view
        add_element(card_view)
        @level_ui_elements << card_view
      end
    end
  end

  def clear_level_ui
    @level_ui_elements&.each do |el|
      el.remove if el.respond_to?(:remove)
      @elements.delete(el) if defined?(@elements) && @elements
    end
    @level_ui_elements = []
    @options_cards = []
  end
end

