# frozen_string_literal: true

load File.join(Dir.pwd, "test", "test_helper.rb")
require "services/save_service"

require "minitest/autorun"
require "tmpdir"
require "json"

class SaveServiceTest < Minitest::Test
  def test_load_missing_file_returns_defaults
    Dir.mktmpdir do |dir|
      path = File.join(dir, "none.json")
      svc = SaveService.new(save_path: path)
      p = svc.load_progress
      assert_equal 0, p.highest_score
      assert p.sound_enabled
    end
  end

  def test_round_trip
    Dir.mktmpdir do |dir|
      path = File.join(dir, "save_data.json")
      svc = SaveService.new(save_path: path)
      p = PlayerProgress.from_hash(highest_score: 42, completed_sections: 3, last_difficulty: "medium",
                                   last_mode: "match_pairs", sound_enabled: false)
      svc.save_progress(p)
      p2 = svc.load_progress
      assert_equal 42, p2.highest_score
      assert_equal 3, p2.completed_sections
      assert_equal "medium", p2.last_difficulty
      assert_equal false, p2.sound_enabled
      assert_equal "garden", p2.theme_key
    end
  end

  def test_theme_key_round_trip
    Dir.mktmpdir do |dir|
      path = File.join(dir, "save_data.json")
      svc = SaveService.new(save_path: path)
      p = PlayerProgress.from_hash(theme_key: "twilight", highest_score: 1)
      svc.save_progress(p)
      p2 = svc.load_progress
      assert_equal "twilight", p2.theme_key
    end
  end

  def test_corrupt_json_falls_back
    Dir.mktmpdir do |dir|
      path = File.join(dir, "bad.json")
      File.write(path, "{ not json")
      svc = SaveService.new(save_path: path)
      p = svc.load_progress
      assert_equal 0, p.highest_score
    end
  end
end
