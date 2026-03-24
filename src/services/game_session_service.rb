require_relative "../models/level"

class GameSessionService
  def initialize(level_generator:, scoring_service:, save_service:, player_progress:, audio_manager: nil)
    @level_generator = level_generator
    @scoring_service = scoring_service
    @save_service = save_service
    @player_progress = player_progress
    @audio_manager = audio_manager

    reset_session_state
  end

  attr_reader :mode, :difficulty, :current_level, :score, :stars, :completed_sections, :levels_total, :stats,
              :current_streak

  def start_session(mode:, difficulty:)
    @mode = mode
    @difficulty = difficulty.to_sym

    @completed_sections = 0
    @score = 0
    @stars = nil
    @current_streak = 0
    reset_level_state

    @stats = {
      total_attempts: 0,
      total_correct: 0,
      level_durations_ms: []
    }

    @levels_total = levels_total_for(mode: @mode, difficulty: @difficulty)
    @previous_payload = nil

    load_next_level!
  end

  def session_running?
    !@current_level.nil? && @stars.nil?
  end

  def register_find_color_attempt(correct:, click_duration_ms:)
    @stats[:total_attempts] += 1
    if correct
      @stats[:total_correct] += 1
      @current_streak += 1
      @score += @scoring_service.score_correct(
        correct_duration_ms: click_duration_ms,
        difficulty: @difficulty
      )
      @score += @scoring_service.streak_bonus_points(streak_after_this_correct: @current_streak)
    else
      @current_streak = 0
    end
  end

  def register_pair_attempt(match:, pair_duration_ms:)
    @stats[:total_attempts] += 1
    if match
      @stats[:total_correct] += 1
      @current_streak += 1
      @score += @scoring_service.score_correct(
        correct_duration_ms: pair_duration_ms,
        difficulty: @difficulty
      )
      @score += @scoring_service.streak_bonus_points(streak_after_this_correct: @current_streak)
    else
      @current_streak = 0
    end
  end

  def complete_current_level!
    elapsed_level_ms = elapsed_level_ms_now
    @stats[:level_durations_ms] << elapsed_level_ms

    @score += @scoring_service.score_level_complete
    @completed_sections += 1

    if @completed_sections >= @levels_total
      finalize_session!
      return false
    end

    load_next_level!
    true
  end

  private

  def reset_session_state
    @mode = nil
    @difficulty = nil
    @current_level = nil
    @score = 0
    @stars = nil
    @completed_sections = 0
    @levels_total = 0
    @stats = nil
    @current_level_start_ms = nil
    @previous_payload = nil
    @current_streak = 0
  end

  def reset_level_state
    @current_level_start_ms = now_ms
    @current_level = nil
  end

  def load_next_level!
    @current_level_start_ms = now_ms

    next_index = @completed_sections + 1

    @current_level = @level_generator.generate_level(
      mode: @mode,
      difficulty: @difficulty,
      index: next_index,
      total: @levels_total,
      previous_payload: @previous_payload
    )

    @previous_payload = @current_level.payload
  end

  def levels_total_for(mode:, difficulty:)
    cfg = GameConfig::DIFFICULTY.fetch(difficulty)
    case mode
    when :find_color
      cfg[:find_color_levels_total]
    when :match_pairs
      cfg[:pairs_levels_total]
    when :ton_catch
      cfg[:find_color_levels_total]
    else
      raise "Bilinmeyen mod: #{mode.inspect}"
    end
  end

  def elapsed_level_ms_now
    (now_ms - @current_level_start_ms).to_i
  end

  def finalize_session!
    @stars = @scoring_service.stars_for(stats: @stats, difficulty: @difficulty)
    update_and_persist_progress!
  end

  def update_and_persist_progress!
    @player_progress.highest_score = [@player_progress.highest_score.to_i, @score.to_i].max
    @player_progress.completed_sections = @player_progress.completed_sections.to_i + @levels_total.to_i
    @player_progress.last_difficulty = @difficulty.to_s
    @player_progress.last_mode = @mode.to_s

    if @audio_manager
      @player_progress.sound_enabled = @audio_manager.sound_enabled?
    end

    @save_service.save_progress(@player_progress)
  end

  def now_ms
    (Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)).to_f
  end
end

