require_relative "../ui/button"
require_relative "../core/animation_helper"
require_relative "../config/game_config"
require_relative "../config/visual_theme"
require_relative "../utils/color_utils"

class BaseScene
  def initialize(game, state_machine)
    @game = game
    @state_machine = state_machine

    @animation_helper = AnimationHelper.new
    @input_handler = @game.input_handler

    @elements = []
    @buttons = []

    build_background
  end

  def enter(_args = {})
    cfg = back_button_config
    add_back_button(
      text: cfg[:text],
      x: cfg[:x],
      y: cfg[:y],
      width: cfg[:width],
      height: cfg[:height]
    )
  end

  def exit
    @elements.each do |e|
      if e.respond_to?(:remove)
        e.remove
      end
    end
    @buttons.clear
    @elements.clear
  end

  def update(dt)
    @animation_helper.update(dt)
    update_background_motion(dt)

    mouse_x = Window.mouse_x
    mouse_y = Window.mouse_y
    @buttons.each do |button|
      next unless button.respond_to?(:update_hover)

      button.update_hover(mouse_x: mouse_x, mouse_y: mouse_y)
    end
  end

  def handle_mouse_down(_event)
  end

  def click_first_matching_button(px, py)
    @buttons.each do |btn|
      next unless btn.respond_to?(:click!) && btn.respond_to?(:contains_point?)
      next unless btn.contains_point?(px, py)

      btn.click!(px, py)
      return true
    end
    false
  end

  protected

  def now_ms
    (Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)).to_f
  end

  def add_element(obj)
    @elements << obj
    obj
  end

  def back_button_config
    {
      text: Texts::ALL[:back],
      x: GameConfig::TOP_LEFT_PADDING,
      y: GameConfig::TOP_LEFT_PADDING,
      width: GameConfig::BACK_BUTTON_WIDTH,
      height: GameConfig::BACK_BUTTON_HEIGHT
    }
  end

  def add_back_button(text:, x:, y:, width:, height:)
    font_size = [26, (height.to_f * 0.42).to_i].max
    font_size = [font_size, 16].max

    back_button = Button.new(
      x: x,
      y: y,
      width: width,
      height: height,
      text: text,
      font_size: font_size,
      on_click: -> { handle_back_click },
      fill_color: "#F7FFFA",
      border_color: "#2F8A2F",
      text_color: "#145A14",
      animation_helper: @animation_helper,
      audio_manager: @game.audio_manager
    )

    @buttons << back_button
    add_element(back_button)
  end

  def handle_back_click
    @state_machine.go_back(fallback_scene_key: :menu)
  end

  def build_background
    @background = []
    @cloud_drift_circles = []
    @cloud_base_x = []
    @sun_discs = []
    @ambient_sparkles = []
    @grass_blades = []

    w = GameConfig::WINDOW_WIDTH
    h = GameConfig::WINDOW_HEIGHT
    t = VisualTheme.bundle(@game.player_progress.theme_key)

    gx, gy = t[:sun_center]

    # ── Sky bloom glow behind sun ──
    t[:bloom].each do |rad, col, op|
      @background << Circle.new(x: gx, y: gy, radius: rad, color: col, opacity: op, z: 0)
    end

    # ── Sky gradient bands ──
    t[:sky_bands].each do |top, bottom, col|
      @background << Rectangle.new(
        x: 0, y: top,
        width: w, height: bottom - top,
        color: col, z: 0
      )
    end

    # ── Sun rays ──
    7.times do |i|
      ang = -Math::PI * 0.42 + i * (Math::PI / 14.0)
      x_far = gx + Math.cos(ang) * 920
      y_far = gy + Math.sin(ang) * 920
      @background << Triangle.new(
        x1: gx, y1: gy,
        x2: gx + Math.cos(ang - 0.04) * 420,
        y2: gy + Math.sin(ang - 0.04) * 420,
        x3: gx + Math.cos(ang + 0.04) * 420,
        y3: gy + Math.sin(ang + 0.04) * 420,
        color: t[:ray_inner],
        z: 0,
        opacity: t[:ray_inner_op]
      )
      @background << Triangle.new(
        x1: gx + Math.cos(ang - 0.04) * 280, y1: gy + Math.sin(ang - 0.04) * 280,
        x2: x_far, y2: y_far,
        x3: gx + Math.cos(ang + 0.04) * 280, y3: gy + Math.sin(ang + 0.04) * 280,
        color: t[:ray_outer],
        z: 0,
        opacity: t[:ray_outer_op]
      )
    end

    # ── Sun / Moon disc ──
    hox, hoy = t[:sun_hot_offset]
    is_sun = t[:celestial] == :sun
    t[:sun_disc_specs].each_with_index do |(rad, col, op), idx|
      ox = is_sun && idx == 3 ? hox : 0
      oy = is_sun && idx == 3 ? hoy : 0
      c = Circle.new(x: gx + ox, y: gy + oy, radius: rad, color: col, opacity: op, z: 1)
      @sun_discs << { obj: c, base_r: rad.to_f }
      @background << c
    end

    # ── Animated clouds ──
    cloud_specs = [
      [110, 72, 38], [250, 95, 44], [420, 68, 36], [580, 88, 40], [760, 70, 42],
      [920, 92, 39], [1080, 78, 41]
    ]
    cloud_specs.each_with_index do |(cx, cy, r), i|
      [-r * 0.45, 0, r * 0.5].each_with_index do |dx, j|
        tint = j == 1 ? "#FFFFFF" : ColorUtils.mix_hex(t[:cloud_mix], "#FFFFFF", 0.55)
        c = Circle.new(
          x: cx + dx, y: cy,
          radius: r * (0.85 + (i % 3) * 0.05),
          color: tint,
          opacity: 0.82,
          z: 1
        )
        @cloud_drift_circles << c
        @cloud_base_x << (cx + dx).to_f
        @background << c
      end
    end
    @cloud_phase = 0.0

    # ── Hills ──
    t[:hills].each do |hx, hy, hr, col, op|
      @background << Circle.new(x: hx, y: hy, radius: hr, color: col, opacity: op, z: 2)
    end

    # ── Grass stripes ──
    grass_y = t[:grass_y]
    y_cursor = grass_y
    t[:grass_stripes_heights].each_with_index do |stripe_h, idx|
      col = t[:grass_colors][idx]
      sh = [stripe_h, 1].max
      @background << Rectangle.new(x: 0, y: y_cursor, width: w, height: sh, color: col, z: 2)
      y_cursor += sh
    end
    last_h = [h - y_cursor, 1].max
    @background << Rectangle.new(x: 0, y: y_cursor, width: w, height: last_h, color: t[:grass_last], z: 2)

    hz_col, hz_op = t[:horizon]
    @background << Rectangle.new(x: 0, y: grass_y - 7, width: w, height: 14, color: hz_col, opacity: hz_op, z: 2)

    # ── Animated grass blades ──
    mix_a, mix_b = t[:grass_blade_mix]
    18.times do |i|
      bx = 40 + (i * 67.0) % (w - 80)
      by = 520 + (i % 5) * 14
      blade = Line.new(
        x1: bx, y1: by + 10,
        x2: bx + 3, y2: by,
        width: 3,
        color: ColorUtils.mix_hex(mix_a, mix_b, 0.35 + (i % 3) * 0.1),
        z: 3,
        opacity: 0.65
      )
      @grass_blades << { obj: blade, base_x1: bx, base_x2: bx + 3, base_y1: by + 10, base_y2: by, phase: i * 0.4 }
      @background << blade
    end

    # ── Flowers ──
    t[:flowers].each do |fx, fy, petal, cent|
      6.times do |k|
        ang = k * (Math::PI / 3)
        @background << Circle.new(
          x: fx + Math.cos(ang) * 6,
          y: fy + Math.sin(ang) * 6,
          radius: 5,
          color: petal,
          opacity: 0.96,
          z: 4
        )
      end
      @background << Circle.new(x: fx, y: fy, radius: 3.5, color: cent, opacity: 1.0, z: 5)
    end

    cols_spark = t[:sparkles]
    GameConfig::BG_AMBIENT_SPARKLES.times do |i|
      px = 30 + (i * 47.3 % (w - 60))
      py = 130 + (i * 71.7 % 420)
      ph = i * 0.37
      rad = 1.2 + (i % 4) * 0.65
      c = Circle.new(
        x: px, y: py,
        radius: rad,
        color: cols_spark[i % cols_spark.size],
        opacity: 0.22,
        z: 3
      )
      @ambient_sparkles << { obj: c, base_x: px, base_y: py, phase: ph, speed: 0.7 + (i % 5) * 0.11 }
      @background << c
    end

    vig_col, vig_op = t[:vignette]
    @background << Rectangle.new(x: 0, y: 0, width: 28, height: h, color: vig_col, opacity: vig_op, z: 6)
    @background << Rectangle.new(x: w - 28, y: 0, width: 28, height: h, color: vig_col, opacity: vig_op, z: 6)

    @background.each { |obj| add_element(obj) }
  end

  def update_background_motion(dt)
    dt = dt.to_f
    @cloud_phase = (@cloud_phase || 0.0) + dt * GameConfig::CLOUD_DRIFT_SPEED

    if @cloud_drift_circles && @cloud_base_x
      @cloud_drift_circles.each_with_index do |c, i|
        base = @cloud_base_x[i]
        next unless base && c.respond_to?(:x=)

        c.x = base + 18 * Math.sin(@cloud_phase + i * 0.61)
      end
    end

    @sun_phase = (@sun_phase || 0.0) + dt * 0.9
    s = 1.0 + 0.04 * Math.sin(@sun_phase)
    if @sun_discs
      @sun_discs.each do |entry|
        obj = entry[:obj]
        br = entry[:base_r]
        next unless obj.respond_to?(:radius=) && br

        obj.radius = br * s
      end
    end

    sp = @bg_sparkle_phase = (@bg_sparkle_phase || 0.0) + dt * GameConfig::BG_POLLEN_DRIFT_SPEED
    if @ambient_sparkles
      @ambient_sparkles.each do |entry|
        o = entry[:obj]
        next unless o

        ph = (entry[:phase] || 0.0) + sp * entry[:speed].to_f
        if o.respond_to?(:opacity=)
          o.opacity = 0.12 + 0.38 * (0.5 + 0.5 * Math.sin(ph))
        end
        if o.respond_to?(:x=) && entry[:base_x]
          o.x = entry[:base_x] + 6 * Math.sin(ph * 0.7)
        end
        if o.respond_to?(:y=) && entry[:base_y]
          o.y = entry[:base_y] + 4 * Math.cos(ph * 0.55)
        end
      end
    end

    gb = @grass_blade_phase = (@grass_blade_phase || 0.0) + dt * 2.2
    if @grass_blades
      @grass_blades.each_with_index do |entry, i|
        b = entry[:obj]
        next unless b && b.respond_to?(:x1=)

        sway = 2.5 * Math.sin(gb + entry[:phase].to_f + i * 0.2)
        b.x1 = entry[:base_x1] + sway
        b.x2 = entry[:base_x2] + sway
      end
    end
  end
end

