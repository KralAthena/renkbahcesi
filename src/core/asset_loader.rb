class AssetLoader
  SOUND_ROOT = File.expand_path("../../assets/sounds", __dir__)
  EFFECTS_ROOT = File.join(SOUND_ROOT, "effects")
  MUSIC_ROOT = File.join(SOUND_ROOT, "music")

  FONT_ROOT = File.expand_path("../../assets/fonts", __dir__)
  IMAGE_ROOT = File.expand_path("../../assets/images", __dir__)

  SOUND_EXT_CANDIDATES = %w[.wav .mp3 .ogg .flac].freeze

  def resolve_sound_path(effect_key)
    effects_root = File.join(SOUND_ROOT, "effects")
    SOUND_EXT_CANDIDATES.each do |ext|
      candidate = File.join(effects_root, "#{effect_key}#{ext}")
      return candidate if File.file?(candidate)
    end
    nil
  end

  def resolve_music_path(music_key)
    music_ext_candidates = %w[.mp3 .ogg .wav .flac].freeze
    music_ext_candidates.each do |ext|
      candidate = File.join(MUSIC_ROOT, "#{music_key}#{ext}")
      return candidate if File.file?(candidate)
    end
    nil
  end

  def resolve_font_path(font_file_name)
    path = File.join(FONT_ROOT, font_file_name)
    File.file?(path) ? path : nil
  end

  def resolve_image_path(image_path_relative)
    candidate = File.join(IMAGE_ROOT, image_path_relative)
    File.file?(candidate) ? candidate : nil
  end

  def load_sound_fx(effect_key)
    path = resolve_sound_path(effect_key)
    return nil if path.nil?

    Ruby2D::Sound.new(path)
  rescue StandardError => e
    warn "[asset_loader] Sound yüklenemedi (#{effect_key}): #{e.message}"
    nil
  end

  def load_music(music_key)
    path = resolve_music_path(music_key)
    return nil if path.nil?

    Ruby2D::Music.new(path)
  rescue StandardError => e
    warn "[asset_loader] Music yüklenemedi (#{music_key}): #{e.message}"
    nil
  end
end

