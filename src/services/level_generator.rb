require_relative "../models/color_card"
require_relative "../models/level"
require_relative "../utils/randomizer"
require_relative "../utils/color_utils"
require_relative "../config/game_config"
require_relative "../config/colors"

class LevelGenerator
  def initialize(randomizer: Randomizer.new)
    @randomizer = randomizer
  end

  def generate_level(mode:, difficulty:, index:, total:, previous_payload: nil)
    case mode
    when :find_color
      generate_find_color_level(difficulty: difficulty, index: index, total: total, previous_payload: previous_payload)
    when :match_pairs
      generate_match_pairs_level(difficulty: difficulty, index: index, total: total)
    when :ton_catch
      generate_find_color_level(difficulty: difficulty, index: index, total: total, previous_payload: previous_payload, ton_catch: true)
    else
      raise "Bilinmeyen mod: #{mode.inspect}"
    end
  end

  private

  def active_color_defs
    Colors.active_colors
  end

  def generate_find_color_level(difficulty:, index:, total:, previous_payload:, ton_catch: false)
    cfg = GameConfig::DIFFICULTY.fetch(difficulty)
    options_count = cfg[:find_color_options_count]

    previous_target_family_id = previous_payload && previous_payload[:target_family_id]

    target_def = select_target_color_def(previous_target_family_id)

    option_family_ids = [target_def[:family_id]]
    while option_family_ids.size < options_count
      candidate = @randomizer.choice(active_color_defs)
      next if option_family_ids.include?(candidate[:family_id])

      option_family_ids << candidate[:family_id]
    end

    option_cards = option_family_ids.map.with_index do |family_id, idx|
      defn = active_color_defs.find { |c| c[:family_id] == family_id }
      display_hex = display_hex_for_level(defn[:hex], difficulty: difficulty, ton_catch: ton_catch)

      ColorCard.new(
        id: "opt_#{family_id}_#{idx}_#{index}",
        base_color_id: defn[:id],
        family_id: defn[:family_id],
        display_hex: display_hex,
        display_name: defn[:ad],
        object_key: defn[:object_key],
        sound_key: defn[:ses_adi]
      )
    end

    option_cards = @randomizer.shuffle(option_cards)

    Level.new(
      mode: :find_color,
      difficulty: difficulty,
      index: index,
      total: total,
      payload: {
        target_family_id: target_def[:family_id],
        target_display_name: target_def[:ad],
        options: option_cards
      }.merge(ton_catch ? { ton_catch: true } : {})
    )
  end

  def generate_match_pairs_level(difficulty:, index:, total:)
    cfg = GameConfig::DIFFICULTY.fetch(difficulty)
    pairs_count = cfg[:pairs_pairs_count]

    chosen_defs = @randomizer.sample_without_replacement(active_color_defs, pairs_count)
    chosen_family_ids = chosen_defs.map { |d| d[:family_id] }

    deck = []
    chosen_family_ids.each_with_index do |family_id, i|
      defn = active_color_defs.find { |c| c[:family_id] == family_id }
      2.times do |j|
        deck << ColorCard.new(
          id: "card_#{family_id}_#{i}_#{j}_#{index}",
          base_color_id: defn[:id],
          family_id: defn[:family_id],
          display_hex: defn[:hex],
          display_name: defn[:ad],
          object_key: defn[:object_key],
          sound_key: defn[:ses_adi]
        )
      end
    end

    Level.new(
      mode: :match_pairs,
      difficulty: difficulty,
      index: index,
      total: total,
      payload: {
        pairs_count: pairs_count,
        deck: @randomizer.shuffle(deck),
        family_ids: chosen_family_ids
      }
    )
  end

  def select_target_color_def(previous_target_family_id)
    defs = active_color_defs
    return @randomizer.choice(defs) if defs.length < 2

    10.times do
      candidate = @randomizer.choice(defs)
      return candidate if previous_target_family_id.nil? || candidate[:family_id] != previous_target_family_id
    end

    @randomizer.choice(defs)
  end

  def display_hex_for_level(hex, difficulty:, ton_catch:)
    return hex unless difficulty == :hard

    strength = ton_catch ? 0.18 : 0.14

    direction = @randomizer.choice([:lighten, :darken])
    ColorUtils.tone_variation_hex(hex, strength, direction)
  end
end

