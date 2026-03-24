class ScoringService
  def initialize(config: GameConfig)
    @config = config
  end

  def score_correct(correct_duration_ms:, difficulty:)
    base = @config::SCORING[:correct_base_points]
    quick_bonus_threshold_ms = @config::DIFFICULTY.fetch(difficulty)[:quick_bonus_threshold_ms]

    bonus = 0
    bonus = @config::SCORING[:quick_bonus_points] if correct_duration_ms <= quick_bonus_threshold_ms

    base + bonus
  end

  def streak_bonus_points(streak_after_this_correct:)
    s = streak_after_this_correct.to_i
    return 0 if s < 2

    step = @config::SCORING[:streak_bonus_per_step]
    cap = @config::SCORING[:streak_bonus_cap]
    raw = (s - 1) * step
    [raw, cap].min
  end

  def score_level_complete
    @config::SCORING[:level_complete_points]
  end

  def stars_for(stats:, difficulty:)
    total_attempts = [stats[:total_attempts].to_i, 1].max
    total_correct = stats[:total_correct].to_i
    accuracy = total_correct.to_f / total_attempts.to_f

    level_durations = Array(stats[:level_durations_ms])
    avg_level_ms = if level_durations.empty?
                      999_999
                    else
                      level_durations.sum.to_f / level_durations.size
                    end

    quick_threshold_ms = @config::DIFFICULTY.fetch(difficulty)[:quick_bonus_threshold_ms]
    speed_good_limit = quick_threshold_ms * 1.35

    if accuracy >= @config::SCORING[:star_min_points_accuracy_3] && avg_level_ms <= speed_good_limit
      3
    elsif accuracy >= @config::SCORING[:star_min_accuracy_2]
      2
    else
      1
    end
  end

  def estimate_stars(stats:, difficulty:)
    stars_for(stats: stats, difficulty: difficulty).clamp(1, 3)
  rescue StandardError
    1
  end
end
