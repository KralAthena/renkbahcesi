# frozen_string_literal: true

require "ruby2d"

def resolve_game_rb
  pwd_root = File.expand_path(Dir.pwd)
  file_root = File.expand_path(__dir__)
  [pwd_root, file_root].uniq.filter_map do |root|
    path = File.join(root, "src", "game.rb")
    path if File.file?(path)
  end.first
end

game_rb = resolve_game_rb
unless game_rb
  warn "src/game.rb bulunamadı."
  warn "Çözüm: Terminalde oyun klasörüne cd ile girin, sonra: ruby main.rb"
  warn "Kalıcı çözüm: Klasör adını ASCII yapın (ör. renkbahcesi)."
  exit 1
end

load game_rb

Game.new.run
