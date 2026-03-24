# frozen_string_literal: true

load File.join(Dir.pwd, "test", "test_helper.rb")
require "services/scoring_service"

require "minitest/autorun"

class ScoringServiceTest < Minitest::Test
  def setup
    @svc = ScoringService.new(config: GameConfig)
  end

  def test_score_correct_base
    pts = @svc.score_correct(correct_duration_ms: 5000, difficulty: :easy)
    assert_equal GameConfig::SCORING[:correct_base_points], pts
  end

  def test_score_correct_quick_bonus
    thr = GameConfig::DIFFICULTY[:easy][:quick_bonus_threshold_ms]
    with_bonus = @svc.score_correct(correct_duration_ms: thr, difficulty: :easy)
    base = GameConfig::SCORING[:correct_base_points]
    assert_equal base + GameConfig::SCORING[:quick_bonus_points], with_bonus
  end

  def test_streak_bonus_zero_for_first
    assert_equal 0, @svc.streak_bonus_points(streak_after_this_correct: 1)
  end

  def test_streak_bonus_from_two
    assert_equal 2, @svc.streak_bonus_points(streak_after_this_correct: 2)
    assert_operator @svc.streak_bonus_points(streak_after_this_correct: 10), :<=, GameConfig::SCORING[:streak_bonus_cap]
  end

  def test_stars_for_not_always_one
    stats = { total_attempts: 10, total_correct: 9, level_durations_ms: [2000, 2100, 2050] }
    stars = @svc.stars_for(stats: stats, difficulty: :easy)
    assert_operator stars, :>=, 1
    assert_operator stars, :<=, 3
  end
end
