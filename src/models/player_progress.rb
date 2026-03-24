require_relative "../config/visual_theme"

class PlayerProgress
  DEFAULT = {
    highest_score: 0,
    completed_sections: 0,
    last_difficulty: "easy",
    last_mode: "find_color",
    sound_enabled: true,
    theme_key: "garden"
  }.freeze

  attr_accessor :highest_score, :completed_sections, :last_difficulty, :last_mode, :sound_enabled, :theme_key

  def initialize(highest_score:, completed_sections:, last_difficulty:, last_mode:, sound_enabled:, theme_key:)
    @highest_score = highest_score
    @completed_sections = completed_sections
    @last_difficulty = last_difficulty
    @last_mode = last_mode
    @sound_enabled = sound_enabled
    @theme_key = theme_key
  end

  def self.from_hash(data)
    raw = data || {}
    sym = raw.transform_keys { |k| k.respond_to?(:to_sym) ? k.to_sym : k }
    safe = DEFAULT.merge(sym)
    tk = (safe[:theme_key] || DEFAULT[:theme_key]).to_s
    tk = DEFAULT[:theme_key] unless VisualTheme::KEYS.include?(tk)

    new(
      highest_score: safe[:highest_score].to_i,
      completed_sections: safe[:completed_sections].to_i,
      last_difficulty: (safe[:last_difficulty] || DEFAULT[:last_difficulty]).to_s,
      last_mode: (safe[:last_mode] || DEFAULT[:last_mode]).to_s,
      sound_enabled: safe.key?(:sound_enabled) ? !!safe[:sound_enabled] : DEFAULT[:sound_enabled],
      theme_key: tk
    )
  end

  def to_h
    {
      highest_score: @highest_score,
      completed_sections: @completed_sections,
      last_difficulty: @last_difficulty,
      last_mode: @last_mode,
      sound_enabled: @sound_enabled,
      theme_key: theme_key.to_s
    }
  end
end

