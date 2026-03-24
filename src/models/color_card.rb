class ColorCard
  attr_reader :id, :base_color_id, :family_id, :display_hex, :display_name, :object_key, :sound_key

  def initialize(id:, base_color_id:, family_id:, display_hex:, display_name:, object_key:, sound_key:)
    @id = id
    @base_color_id = base_color_id
    @family_id = family_id
    @display_hex = display_hex
    @display_name = display_name
    @object_key = object_key
    @sound_key = sound_key
  end

  def matches_family?(other_card)
    other_card && other_card.family_id == family_id
  end
end

