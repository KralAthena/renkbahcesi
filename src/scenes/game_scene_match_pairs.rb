require_relative "base_scene"
require_relative "../ui/card_view"
require_relative "../core/timer"
require_relative "../ui/panel"
require_relative "../utils/text_align"

class GameSceneMatchPairs < BaseScene
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

    @session = @game.game_session_service
    @level = @session.current_level
    @pairs_count = @level.payload[:pairs_count]
    @matched_pairs_found = 0

    @open_cards = []
    @pending_resolution = nil
    @pair_first_flipped_at_ms = nil

    @round_timer = Timer.new
    @round_timer.start

    @task_text = Ruby2D::Text.new(
      Texts::ALL[:match_pairs_task],
      x: 0,
      y: GameConfig::TASK_TEXT_Y,
      size: GameConfig::TASK_TEXT_SIZE - 6,
      color: "#1B5E20",
      z: 30
    )
    TextAlign.center_horizontally(@task_text, GameConfig::WINDOW_WIDTH)
    add_element(@task_text)

    build_top_buttons
    build_score_panel
    load_current_level_ui
  end

  def handle_back_click
    @state_machine.go_to(:menu, args: {}, push: false)
  end

  def update(dt)
    super
    @cards&.each { |c| c.update(dt) if c.respond_to?(:update) }
    update_progress_ui
    process_pending_resolution
  end

  def handle_mouse_down(event)
    return unless @input_handler.accept_click?
    return if @pending_resolution

    px = event.x
    py = event.y

    return if click_first_matching_button(px, py)

    clicked_card = @cards&.find { |card| card.contains_point?(px, py) }
    return unless clicked_card

    return if clicked_card.matched
    return if @open_cards.include?(clicked_card)
    return if @open_cards.length >= GameConfig::PAIRS_MAX_OPEN

    @open_cards << clicked_card
    clicked_card.set_face_up

    if @open_cards.length == 1
      @pair_first_flipped_at_ms = now_ms
      return
    end

    return unless @open_cards.length == 2

    second_card = @open_cards.last
    first_card = @open_cards.first

    pair_duration_ms = (now_ms - @pair_first_flipped_at_ms).to_i
    match = second_card.color_card.matches_family?(first_card.color_card)

    @session.register_pair_attempt(match: match, pair_duration_ms: pair_duration_ms)

    @pending_resolution = {
      first_card: first_card,
      second_card: second_card,
      match: match,
      resolve_at_ms: now_ms + GameConfig::PAIRS_FLIP_BACK_DELAY_MS
    }

    @input_handler.lock_for(GameConfig::PAIRS_FLIP_BACK_DELAY_MS)
  end

  private

  def build_top_buttons
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
  end

  def toggle_sound
    @game.audio_manager.toggle_sound
    @game.player_progress.sound_enabled = @game.audio_manager.sound_enabled?
    @game.save_service.save_progress(@game.player_progress)

    @btn_sound.set_text(@game.audio_manager.sound_enabled? ? "Ses Açık" : "Ses Kapalı")
  end

  def build_score_panel
    ph = GameConfig::SCORE_PANEL_HEIGHT_MATCH
    @score_panel = Panel.new(
      x: GameConfig::SCORE_PANEL_X,
      y: GameConfig::SCORE_PANEL_Y,
      width: GameConfig::SCORE_PANEL_WIDTH,
      height: ph,
      radius: 22,
      fill_color: "#ECFDF5",
      border_color: "#059669",
      border_width: 5,
      opacity: 0.95,
      z: 25
    )
    add_element(@score_panel)

    py = GameConfig::SCORE_PANEL_Y
    @hud_line1 = Ruby2D::Text.new("", x: 0, y: py + 12, size: 23, color: "#145A14", z: 40)
    @hud_line2 = Ruby2D::Text.new("", x: 0, y: py + 40, size: 21, color: "#1B5E20", z: 40)

    add_element(@hud_line1)
    add_element(@hud_line2)
  end

  def update_progress_ui
    stats = @session.stats
    moves = stats[:total_attempts].to_i

    estimate_stars = @game.scoring_service.estimate_stars(
      stats: stats,
      difficulty: @session.difficulty
    )

    streak = @session.current_streak.to_i
    streak_part = streak >= 1 ? "  ·  #{Texts::ALL[:streak_label]} #{streak}" : ""

    total_seconds = @round_timer.elapsed_ms / 1000
    mm = (total_seconds / 60).to_i
    ss = (total_seconds % 60).to_i

    @hud_line1.text = "#{Texts::ALL[:result_score]}: #{@session.score}     Yıldız: #{estimate_stars}/3"
    TextAlign.center_horizontally(@hud_line1, GameConfig::WINDOW_WIDTH)

    @hud_line2.text = "#{Texts::ALL[:progress_moves]}: #{moves}#{streak_part}     #{format('Süre: %02d:%02d', mm, ss)}"
    TextAlign.center_horizontally(@hud_line2, GameConfig::WINDOW_WIDTH)
  end

  def process_pending_resolution
    return unless @pending_resolution
    return unless now_ms >= @pending_resolution[:resolve_at_ms]

    first_card = @pending_resolution[:first_card]
    second_card = @pending_resolution[:second_card]
    match = @pending_resolution[:match]

    if match
      @game.audio_manager.play_correct
      first_card.set_face_up
      second_card.set_face_up
      first_card.set_correct
      second_card.set_correct
      @matched_pairs_found += 1
      @open_cards.clear

      if @matched_pairs_found >= @pairs_count
        @game.audio_manager.play_level_complete
        continue = @session.complete_current_level!
        if continue
          @level = @session.current_level
          @pairs_count = @level.payload[:pairs_count]
          reload_level!
        else
          @state_machine.go_to(:result, args: {}, push: true)
        end
      end
    else
      @game.audio_manager.play_wrong
      first_card.set_face_down
      second_card.set_face_down
      @open_cards.clear
    end

    @pending_resolution = nil
  end

  def reload_level!
    load_current_level_ui
  end

  def load_current_level_ui
    clear_level_ui

    @level = @session.current_level
    payload = @level.payload
    @pairs_count = payload[:pairs_count]
    deck_cards = payload[:deck]

    @matched_pairs_found = 0
    @open_cards = []
    @pending_resolution = nil

    cols, rows = layout_for_cards(deck_cards.length)

    gap_x = GameConfig::GRID_GAP_X
    gap_y = GameConfig::GRID_GAP_Y

    card_w = (GameConfig::WINDOW_WIDTH - 2 * GameConfig::GRID_PADDING_X - (cols - 1) * gap_x) / cols.to_f
    card_h = (available_height(rows) - (rows - 1) * gap_y) / rows.to_f

    card_w = 140 if card_w < 140
    card_h = 110 if card_h < 110

    total_width = cols * card_w + (cols - 1) * gap_x
    start_x = (GameConfig::WINDOW_WIDTH - total_width) / 2.0
    start_y = GameConfig::GRID_TOP_Y + 10

    @cards = []
    deck_cards.each_with_index do |color_card, idx|
      r = idx / cols
      c = idx % cols
      x = start_x + c * (card_w + gap_x)
      y = start_y + r * (card_h + gap_y)

      @cards << CardView.new(
        x: x,
        y: y,
        width: card_w,
        height: card_h,
        color_card: color_card,
        enabled: true,
        animation_helper: @animation_helper,
        face_down: true
      )
    end

    @round_timer.reset
    @round_timer.start
    @cards.each { |card| add_element(card) }
  end

  def layout_for_cards(deck_size)
    return [2, 2] if deck_size <= 4
    return [4, 2] if deck_size <= 8

    [4, 3]
  end

  def available_height(rows)
    GameConfig::GRID_BOTTOM_Y - GameConfig::GRID_TOP_Y
  end

  def calculated_card_width(cols)
    (GameConfig::WINDOW_WIDTH - 2 * GameConfig::GRID_PADDING_X - (cols - 1) * GameConfig::GRID_GAP_X) / cols.to_f
  end

  def clear_level_ui
    @cards&.each do |card|
      card.remove if card.respond_to?(:remove)
      @elements.delete(card)
    end
    @cards = []
  end
end

