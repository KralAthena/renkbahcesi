require "json"

class SaveService
  def initialize(save_path: nil)
    @save_path = save_path || File.expand_path("../../save_data.json", __dir__)
  end

  def load_progress
    return default_progress unless File.file?(@save_path)

    raw = File.read(@save_path)
    data = JSON.parse(raw)
    PlayerProgress.from_hash(data)
  rescue StandardError => e
    warn "[save_service] Save bozuk/okunamadı. Varsayılanlar kullanılıyor: #{e.message}"
    default_progress
  end

  def save_progress(player_progress)
    data = player_progress.to_h
    payload = JSON.pretty_generate(data)
    tmp = "#{@save_path}.tmp"
    File.write(tmp, payload)
    File.delete(@save_path) if File.file?(@save_path)
    File.rename(tmp, @save_path)
  rescue StandardError => e
    warn "[save_service] Kaydetme başarısız: #{e.message}"
    begin
      tmp_path = "#{@save_path}.tmp"
      File.delete(tmp_path) if File.file?(tmp_path)
    rescue StandardError
      nil
    end
  end

  private

  def default_progress
    PlayerProgress.from_hash({})
  end
end

