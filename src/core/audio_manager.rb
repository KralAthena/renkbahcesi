class AudioManager
  DEFAULT_MUSIC_KEY = :bahce_muzigi

  def initialize(asset_loader:, initial_sound_enabled: true, initial_music_enabled: true)
    @asset_loader = asset_loader

    @sound_enabled = initial_sound_enabled
    @music_enabled = initial_music_enabled

    @music = nil
  end

  def sound_enabled?
    @sound_enabled
  end

  def set_sound_enabled(enabled)
    @sound_enabled = !!enabled
    apply_audio_state
  end

  def toggle_sound
    @sound_enabled = !@sound_enabled
    apply_audio_state
  end

  def play_music(music_key: DEFAULT_MUSIC_KEY, loop: true, volume: nil)
    return unless @sound_enabled && @music_enabled

    @music ||= @asset_loader.load_music(music_key)
    return if @music.nil?

    @music.loop = loop if @music.respond_to?(:loop=)
    @music.volume = volume if volume && @music.respond_to?(:volume=)
    @music.play
  rescue StandardError => e
    warn "[audio_manager] Müzik çalınamadı: #{e.message}"
  end

  def stop_music
    @music&.stop
  rescue StandardError
    nil
  end

  def play_fx(fx_key)
    return unless @sound_enabled

    sound = @asset_loader.load_sound_fx(fx_key)
    return if sound.nil?

    sound.play
  rescue StandardError => e
    warn "[audio_manager] Efekt çalınamadı (#{fx_key}): #{e.message}"
  end

  def play_button
    play_fx(:button_click)
  end

  def play_correct
    play_fx(:correct)
  end

  def play_wrong
    play_fx(:wrong)
  end

  def play_level_complete
    play_fx(:level_complete)
  end

  def play_color(color_sound_key)
    play_fx(color_sound_key)
  end

  private

  def apply_audio_state
    unless @sound_enabled
      stop_music
      return
    end

    play_music if @music_enabled
  end
end

