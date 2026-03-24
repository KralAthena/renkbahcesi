require_relative "config/game_config"
require_relative "config/colors"
require_relative "config/texts"
require_relative "config/visual_theme"

require_relative "core/state_machine"
require_relative "core/asset_loader"
require_relative "core/audio_manager"
require_relative "core/input_handler"
require_relative "core/timer"
require_relative "core/animation_helper"

require_relative "models/color_card"
require_relative "models/level"
require_relative "models/player_progress"

require_relative "services/level_generator"
require_relative "services/scoring_service"
require_relative "services/save_service"
require_relative "services/game_session_service"

require_relative "scenes/base_scene"
require_relative "scenes/splash_scene"
require_relative "scenes/menu_scene"
require_relative "scenes/help_scene"
require_relative "scenes/mode_select_scene"
require_relative "scenes/difficulty_select_scene"
require_relative "scenes/game_scene_find_color"
require_relative "scenes/game_scene_match_pairs"
require_relative "scenes/result_scene"

class Game
  include Ruby2D::DSL

  attr_reader :audio_manager, :save_service, :scoring_service, :game_session_service, :player_progress, :input_handler

  def refresh_window_theme!
    set background: VisualTheme.window_bg(player_progress.theme_key)
  rescue StandardError
    nil
  end

  def initialize
    @asset_loader = AssetLoader.new
    @save_service = SaveService.new
    @player_progress = @save_service.load_progress

    @audio_manager = AudioManager.new(
      asset_loader: @asset_loader,
      initial_sound_enabled: @player_progress.sound_enabled,
      initial_music_enabled: true
    )

    @scoring_service = ScoringService.new
    @level_generator = LevelGenerator.new

    @game_session_service = GameSessionService.new(
      level_generator: @level_generator,
      scoring_service: @scoring_service,
      save_service: @save_service,
      player_progress: @player_progress,
      audio_manager: @audio_manager
    )

    @input_handler = InputHandler.new

    scenes_registry = {
      splash: SplashScene,
      menu: MenuScene,
      help: HelpScene,
      mode_select: ModeSelectScene,
      difficulty_select: DifficultySelectScene,
      game_find_color: GameSceneFindColor,
      game_match_pairs: GameSceneMatchPairs,
      result: ResultScene
    }

    @state_machine = StateMachine.new(self, registry: scenes_registry, initial_scene_key: :splash)
  end

  def run
    set title: GameConfig::WINDOW_TITLE, width: GameConfig::WINDOW_WIDTH, height: GameConfig::WINDOW_HEIGHT
    set resizable: false
    set background: VisualTheme.window_bg(@player_progress.theme_key)

    on :mouse_down do |event|
      @state_machine.handle_mouse_down(event)
    end

    @last_frame_tick = nil
    update do
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
      @last_frame_tick ||= now
      raw_dt = now - @last_frame_tick
      @last_frame_tick = now
      dt = raw_dt.clamp(0.0, 0.05)
      @state_machine.update(dt)
    end

    @audio_manager.play_music if @player_progress.sound_enabled

    show
  end
end

