module Texts
  module_function

  ALL = {
    app_name: "Renk Bahçesi",

    splash_welcome: "Hoş geldin!",
    splash_ready: "Renk bahçesine başlayalım.",

    menu_start: "Başla",
    menu_howto: "Nasıl Oynanır",
    menu_about_sound: "Ses",
    menu_exit: "Çıkış",

    help_title: "Nasıl Oynanır?",
    help_line_1: "Gösterilen rengi bul.",
    help_line_2: "Aynı renkleri eşleştir.",
    help_line_3: "Doğru seçince yıldız kazanırsın.",
    help_line_4: "Yanlış olursa üzülme; hemen tekrar dene.",
    help_line_5: "Kısa süre odaklan: bir görevi bitir, sonra mola ver. Seri yaptıkça ekstra puan kazanırsın!",

    streak_label: "Seri",

    mode_title: "Hangi oyunu oynayalım?",
    mode_find_color: "Rengi Bul",
    mode_match_pairs: "Eşini Bul",
    mode_ton_catch: "Ton Yakala (Yakında)",

    difficulty_title: "Zorluk seç",
    difficulty_easy: "Kolay",
    difficulty_medium: "Orta",
    difficulty_hard: "Zor",

    back: "Geri",
    menu: "Menü",
    sound_on: "Ses: Açık",
    sound_off: "Ses: Kapalı",
    sound_button: "Ses",

    theme_menu_label: "Görünüm: %{name}",
    theme_name_garden: "Bahçe",
    theme_name_twilight: "Alacakaranlık",
    theme_name_contrast: "Kontrast",

    find_color_task_prefix: "%{color} rengi bul!",
    find_color_task_prefix_alt: "%{color} rengi seç!",
    find_color_wrong: "Biraz daha dene!",
    find_color_correct: "Aferin!",
    find_color_level_done: "Bölüm bitti!",

    match_pairs_task: "Aynı renkleri eşleştir — önce bir kart, sonra eşi!",
    match_pairs_wait: "Kontrol ediyorum...",
    match_pairs_wrong: "Yakında!",
    match_pairs_correct: "Eşleşti!",
    match_pairs_level_done: "Tüm eşler bulundu!",

    result_title: "Bölüm Sonu",
    result_score: "Skor",
    result_stars: "Yıldızlar",
    result_restart: "Tekrar Oyna",
    result_menu: "Menüye dön",
    result_play_again_hint: "Hazır olunca tekrar başla!",

    progress_section: "Bölüm",
    progress_moves: "Hamle",
    progress_time: "Süre",
    progress_stars_estimate: "Yıldız (tahmin)",

    ton_catch_unavailable: "Ton Yakala yakında!"
  }.freeze

  def find_color_task(color_name)
    ALL[:find_color_task_prefix] % { color: color_name }
  end

  def match_pairs_task
    ALL[:match_pairs_task]
  end
end

