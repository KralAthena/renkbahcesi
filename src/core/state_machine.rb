class StateMachine
  def initialize(game, registry:, initial_scene_key:)
    @game = game
    @registry = registry
    @scene_stack = []

    @current_scene_key = nil
    @current_scene = nil

    go_to(initial_scene_key, args: {}, push: false)
  end

  def current_scene
    @current_scene
  end

  def go_to(scene_key, args: {}, push: true)
    raise "Bilinmeyen scene: #{scene_key.inspect}" unless @registry.key?(scene_key)

    if @current_scene && push
      @scene_stack << @current_scene_key
    end

    @current_scene&.exit

    @current_scene_key = scene_key
    scene_class = @registry.fetch(scene_key)
    @current_scene = scene_class.new(@game, self)
    @current_scene.enter(args)
  end

  def go_back(fallback_scene_key:)
    target = @scene_stack.pop
    if target.nil?
      go_to(fallback_scene_key, args: {}, push: false)
    else
      go_to(target, args: {}, push: false)
    end
  end

  def update(dt)
    @current_scene&.update(dt)
  end

  def handle_mouse_down(event)
    @current_scene&.handle_mouse_down(event)
  end
end

