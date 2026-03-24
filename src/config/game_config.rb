module GameConfig
  WINDOW_TITLE = "Renk Bahçesi"

  WINDOW_WIDTH = 1280
  WINDOW_HEIGHT = 720

  PANEL_RADIUS = 26
  BORDER_WIDTH = 6

  BACK_BUTTON_WIDTH = 220
  BACK_BUTTON_HEIGHT = 60
  MENU_BUTTON_WIDTH = 320
  MENU_BUTTON_HEIGHT = 74

  BUTTON_HOVER_SCALE = 1.03
  BUTTON_PRESS_SCALE = 0.96
  BUTTON_ANIM_PRESS_MS = 110
  BUTTON_ANIM_HOVER_MS = 120

  CARD_CORNER_RADIUS = 30
  CARD_BORDER_WIDTH = 6
  CARD_WIDTH = 210
  CARD_HEIGHT = 170

  TASK_TEXT_Y = 125
  TASK_TEXT_SIZE = 44

  TOP_LEFT_PADDING = 26
  TOP_TASK_CENTER_Y = 120

  GRID_BOTTOM_Y = 635
  GRID_TOP_Y = 210
  GRID_PADDING_X = 60
  GRID_GAP_X = 24
  GRID_GAP_Y = 22

  SCORE_PANEL_MARGIN_X = 40
  SCORE_PANEL_WIDTH = WINDOW_WIDTH - 2 * SCORE_PANEL_MARGIN_X
  SCORE_PANEL_X = SCORE_PANEL_MARGIN_X
  SCORE_PANEL_HEIGHT = 64
  SCORE_PANEL_HEIGHT_MATCH = 78
  SCORE_PANEL_Y = 625

  SOUND_BUTTON_SIZE = 60
  MENU_BUTTON_SIZE = 60
  MENU_BUTTON_X = 26
  MENU_BUTTON_Y = 26
  SOUND_BUTTON_X = 1190
  SOUND_BUTTON_Y = 26

  WRONG_SHAKE_MS = 420
  MATCH_POP_MS = 190
  GLOW_MS = 520
  BUTTON_PRESS_FLASH_MS = 95
  CARD_IDLE_BOB_SPEED = 4.2
  CARD_FACE_UP_PULSE_SPEED = 2.8
  ICON_SUN_ROTATE_SPEED = 1.35
  CLOUD_DRIFT_SPEED = 0.35
  BG_AMBIENT_SPARKLES = 42
  BG_POLLEN_DRIFT_SPEED = 0.45
  MENU_TITLE_FLOAT_AMPLITUDE = 12
  MENU_TITLE_FLOAT_SPEED = 1.6
  CARD_GLOW_Z = 63

  SPLASH_MS = 1400
  INPUT_SPAM_LOCK_MS = 220
  FIND_COLOR_MAX_ATTEMPTS_PER_LEVEL = 40
  PAIRS_FLIP_BACK_DELAY_MS = 820
  PAIRS_MAX_OPEN = 2

  DIFFICULTY = {
    easy: {
      find_color_options_count: 4,
      find_color_levels_total: 5,
      pairs_pairs_count: 2,
      pairs_levels_total: 5,
      quick_bonus_threshold_ms: 3200,
      max_time_per_level_ms: 80_000
    },
    medium: {
      find_color_options_count: 6,
      find_color_levels_total: 5,
      pairs_pairs_count: 4,
      pairs_levels_total: 5,
      quick_bonus_threshold_ms: 2400,
      max_time_per_level_ms: 65_000
    },
    hard: {
      find_color_options_count: 8,
      find_color_levels_total: 7,
      pairs_pairs_count: 6,
      pairs_levels_total: 4,
      quick_bonus_threshold_ms: 2000,
      max_time_per_level_ms: 55_000
    }
  }.freeze

  SCORING = {
    correct_base_points: 10,
    quick_bonus_points: 5,
    streak_bonus_per_step: 2,
    streak_bonus_cap: 14,
    level_complete_points: 20,
    star_min_points_accuracy_3: 0.90,
    star_min_accuracy_2: 0.75,
    star_hard_penalty_accuracy_threshold: 0.60
  }.freeze

  MAX_COLOR_LABEL_LENGTH = 12
end
