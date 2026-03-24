require_relative "panel"
require_relative "label"
require_relative "../config/game_config"
require_relative "../utils/color_utils"
require_relative "../utils/text_align"

class CardView
  attr_reader :color_card, :x, :y, :width, :height, :matched

  def initialize(
    x:,
    y:,
    width: GameConfig::CARD_WIDTH,
    height: GameConfig::CARD_HEIGHT,
    color_card:,
    on_click: nil,
    enabled: true,
    animation_helper: nil,
    face_down: false
  )
    @x = x.to_f
    @y = y.to_f
    @width = width.to_f
    @height = height.to_f
    @color_card = color_card
    @on_click = on_click
    @enabled = enabled
    @animation_helper = animation_helper
    @matched = false

    @default_fill = "#F5FFF9"
    @default_border = "#16A34A"
    @selected_border = "#FBBF24"
    @correct_border = "#22C55E"
    @wrong_border = "#EF4444"

    @corner_radius = [GameConfig::CARD_CORNER_RADIUS, @width / 2.0, @height / 2.0].min

    @drop_shadow = Panel.new(
      x: @x + 6, y: @y + 10,
      width: @width, height: @height,
      radius: @corner_radius,
      fill_color: "#04120A",
      border_color: "#04120A",
      border_width: 2,
      opacity: 0.22,
      z: 58
    )

    @base_panel = Panel.new(
      x: @x, y: @y,
      width: @width, height: @height,
      radius: @corner_radius,
      fill_color: @default_fill,
      border_color: @default_border,
      border_width: GameConfig::CARD_BORDER_WIDTH,
      opacity: 1.0,
      z: 60
    )

    @selected_panel = Panel.new(
      x: @x, y: @y,
      width: @width, height: @height,
      radius: @corner_radius,
      fill_color: ColorUtils.lighten(@default_fill, 0.05),
      border_color: @selected_border,
      border_width: GameConfig::CARD_BORDER_WIDTH,
      opacity: 0.0,
      z: 61
    )
    @correct_panel = Panel.new(
      x: @x, y: @y,
      width: @width, height: @height,
      radius: @corner_radius,
      fill_color: ColorUtils.lighten(@default_fill, 0.02),
      border_color: @correct_border,
      border_width: GameConfig::CARD_BORDER_WIDTH,
      opacity: 0.0,
      z: 62
    )
    @wrong_panel = Panel.new(
      x: @x, y: @y,
      width: @width, height: @height,
      radius: @corner_radius,
      fill_color: ColorUtils.lighten(@default_fill, 0.02),
      border_color: @wrong_border,
      border_width: GameConfig::CARD_BORDER_WIDTH,
      opacity: 0.0,
      z: 62
    )

    build_face_layers

    @face_down = false
    set_face_down if face_down
  end

  def contains_point?(px, py)
    px >= @x && px <= (@x + @width) && py >= @y && py <= (@y + @height)
  end

  def disable!
    @enabled = false
  end

  def enable!
    @enabled = true
  end

  def click!(px, py)
    return unless @enabled
    return unless contains_point?(px, py)

    @on_click&.call(self)
  end

  def set_face_down
    @face_down = true
    @matched = false

    set_opacity(@face_up_items, 0.0)
    set_opacity(@back_items, 1.0)
    hide_state_panels
  end

  def set_face_up
    @face_down = false
    set_opacity(@face_up_items, 1.0)
    set_opacity(@back_items, 0.0)
    hide_state_panels
  end

  def set_selected
    return if @face_down
    hide_state_panels
    @selected_panel.opacity = 1.0
  end

  def set_correct
    return if @face_down
    hide_state_panels
    @correct_panel.opacity = 1.0
    @matched = true

    return unless @animation_helper

    @animation_helper.spawn_glow_panel(
      x: @x - 8, y: @y - 8,
      width: @width + 16, height: @height + 16,
      radius: @corner_radius + 10,
      fill_color: @color_card.display_hex,
      border_color: "#FFFFFF",
      border_width: 6,
      z: GameConfig::CARD_GLOW_Z,
      duration_ms: GameConfig::GLOW_MS
    )
  end

  def set_wrong
    return if @face_down
    hide_state_panels
    @wrong_panel.opacity = 1.0

    return unless @animation_helper

    shake_targets = @face_up_items + @base_panel.primitives
    shake_targets.concat(@drop_shadow.primitives) if @drop_shadow
    @animation_helper.shake(
      objects: shake_targets,
      amplitude_px: 6,
      duration_ms: GameConfig::WRONG_SHAKE_MS
    )
  end

  def update(dt)
    return unless @enabled
    return if @matched

    dt = dt.to_f
    @idle_phase = (@idle_phase || 0.0) + dt * GameConfig::CARD_IDLE_BOB_SPEED

    if @face_down
      s = Math.sin(@idle_phase)
      if @back_glow && @back_glow_base_r
        @back_glow.radius = @back_glow_base_r * (1.0 + 0.14 * s)
        if @back_glow.respond_to?(:opacity=)
          @back_glow.opacity = 0.55 + 0.35 * (1.0 + s) * 0.5
        end
      end
      if @back_question && @back_question_base_y
        @back_question.y = @back_question_base_y + 12 * s
      end
      return
    end

    @pulse_phase += dt * GameConfig::CARD_FACE_UP_PULSE_SPEED
    if @main_circle && @main_circle_base_r
      @main_circle.radius = @main_circle_base_r * (1.0 + 0.09 * Math.sin(@pulse_phase))
    end
    if @highlight_circle && @highlight_circle.respond_to?(:opacity=)
      @highlight_circle.opacity = 0.38 + 0.22 * Math.sin(@pulse_phase * 1.15)
    end

    animate_sun_rays(dt) if @sun_lines
  end

  def remove
    @drop_shadow.remove if @drop_shadow
    @base_panel.remove
    @selected_panel.remove
    @correct_panel.remove
    @wrong_panel.remove

    (@face_up_items + @back_items).each { |item| item.remove if item.respond_to?(:remove) }
    @face_up_items.clear
    @back_items.clear
  end

  private

  def build_face_layers
    @face_up_items = []
    @back_items = []

    center_x = @x + @width / 2.0
    center_y = @y + @height / 2.0 - 10
    icon_r = [@width, @height].min * 0.22
    question_size = [72, @height * 0.38].min
    name_text_size = [[@height * 0.22, 18].max, 30].min

    @back_question = Ruby2D::Text.new(
      "?",
      x: 0,
      y: center_y + (@height * 0.07),
      size: question_size,
      color: "#4A148C",
      z: 70
    )
    TextAlign.center_horizontally_in(@back_question, @x, @width)
    @back_glow = Circle.new(
      x: center_x,
      y: center_y + 8,
      radius: icon_r * 1.05,
      color: ColorUtils.mix_hex("#E1BEE7", "#B39DDB", 0.45),
      z: 69,
      opacity: 0.82
    )
    @back_items << Circle.new(
      x: center_x,
      y: center_y + 6,
      radius: icon_r * 0.62,
      color: ColorUtils.lighten("#7E57C2", 0.15),
      z: 68,
      opacity: 0.35
    )
    @back_items << @back_glow
    @back_items << Circle.new(
      x: center_x - icon_r * 0.35,
      y: center_y - icon_r * 0.25,
      radius: 5,
      color: "#FFFFFF",
      z: 70,
      opacity: 0.55
    )
    @back_items << Circle.new(
      x: center_x + icon_r * 0.4,
      y: center_y + icon_r * 0.2,
      radius: 4,
      color: "#FFF9C4",
      z: 70,
      opacity: 0.5
    )
    @back_items << @back_question

    @back_glow_base_r = icon_r
    @back_question_base_y = center_y + (@height * 0.07)
    @idle_phase = rand * Math::PI * 2

    hex = ColorUtils.punch_rgb(@color_card.display_hex, 0.14)
    shadow_circle = Circle.new(
      x: center_x + icon_r * 0.1,
      y: center_y + icon_r * 0.14,
      radius: icon_r * 1.05,
      color: ColorUtils.darken(hex, 0.38),
      z: 71,
      opacity: 0.62
    )
    base_circle = Circle.new(
      x: center_x,
      y: center_y,
      radius: icon_r,
      color: hex,
      z: 72
    )
    @main_circle = base_circle
    @main_circle_base_r = icon_r
    @pulse_phase = 0.0

    @highlight_circle = Circle.new(
      x: center_x - icon_r * 0.2,
      y: center_y - icon_r * 0.18,
      radius: icon_r * 0.58,
      color: ColorUtils.lighten(hex, 0.42),
      z: 72,
      opacity: 0.48
    )

    icon_items = build_object_icon(center_x: center_x, center_y: center_y, radius: icon_r)

    label_hex = ColorUtils.darken(hex, 0.52)
    name_text = Ruby2D::Text.new(
      @color_card.display_name[0, GameConfig::MAX_COLOR_LABEL_LENGTH],
      x: 0,
      y: @y + @height - (@height * 0.28),
      size: name_text_size,
      color: label_hex,
      z: 80
    )
    TextAlign.center_horizontally_in(name_text, @x, @width)

    @face_up_items << shadow_circle
    @face_up_items << base_circle
    @face_up_items << @highlight_circle
    @face_up_items.concat(icon_items)
    @face_up_items << name_text

    set_opacity(@face_up_items, 1.0)
    set_opacity(@back_items, 0.0)
  end

  def build_object_icon(center_x:, center_y:, radius:)
    items = []
    key   = @color_card.object_key
    hex   = @color_card.display_hex

    case key
    # ── 🍎 Elma ──────────────────────────────────────────────────
    when :apple
      # body
      items << Circle.new(x: center_x, y: center_y, radius: radius, color: hex, z: 72)
      # shine
      items << Circle.new(
        x: center_x - radius * 0.28, y: center_y - radius * 0.22,
        radius: radius * 0.38, color: "#FFFFFF", opacity: 0.32, z: 73
      )
      # stem
      items << Rectangle.new(
        x: center_x - radius * 0.1, y: center_y - radius * 1.12,
        width: radius * 0.22, height: radius * 0.38,
        color: "#6D4C41", z: 75, opacity: 0.95
      )
      # leaf
      items << Triangle.new(
        x1: center_x - radius * 0.02, y1: center_y - radius * 1.02,
        x2: center_x - radius * 0.65, y2: center_y - radius * 1.32,
        x3: center_x + radius * 0.08, y3: center_y - radius * 1.25,
        color: "#4CAF50", z: 74, opacity: 0.95
      )

    # ── 💧 Damla ─────────────────────────────────────────────────
    when :droplet
      # main teardrop body (two circles + triangle)
      items << Circle.new(x: center_x, y: center_y + radius * 0.15, radius: radius * 0.75, color: hex, z: 72)
      items << Triangle.new(
        x1: center_x, y1: center_y - radius * 0.9,
        x2: center_x - radius * 0.55, y2: center_y + radius * 0.25,
        x3: center_x + radius * 0.55, y3: center_y + radius * 0.25,
        color: hex, z: 72
      )
      # inner highlight
      items << Circle.new(
        x: center_x - radius * 0.22, y: center_y - radius * 0.1,
        radius: radius * 0.28, color: "#FFFFFF", opacity: 0.38, z: 73
      )

    # ── 🍌 Muz (Sarı rengin ikonu) ───────────────────────────────
    when :banana
      # Banana crescent shape: series of overlapping circles forming a curved arc
      bx = center_x
      by = center_y
      9.times do |i|
        t_val = i / 8.0
        angle = Math::PI * 0.15 + t_val * Math::PI * 0.7
        ox = bx + Math.cos(angle) * radius * 1.0
        oy = by - Math.sin(angle) * radius * 0.55 + radius * 0.3
        items << Circle.new(x: ox, y: oy, radius: radius * 0.32, color: hex, z: 72)
      end
      7.times do |i|
        t_val = i / 6.0
        angle = Math::PI * 0.2 + t_val * Math::PI * 0.6
        ox = bx + Math.cos(angle) * radius * 0.62
        oy = by - Math.sin(angle) * radius * 0.38 + radius * 0.25
        items << Circle.new(x: ox, y: oy, radius: radius * 0.28, color: ColorUtils.darken(hex, 0.12), z: 72)
      end
      # tips
      items << Circle.new(
        x: bx + Math.cos(Math::PI * 0.15) * radius * 0.95,
        y: by - Math.sin(Math::PI * 0.15) * radius * 0.5 + radius * 0.3,
        radius: radius * 0.14, color: ColorUtils.darken(hex, 0.32), z: 73
      )
      items << Circle.new(
        x: bx + Math.cos(Math::PI * 0.85) * radius * 0.95,
        y: by - Math.sin(Math::PI * 0.85) * radius * 0.5 + radius * 0.3,
        radius: radius * 0.14, color: ColorUtils.darken(hex, 0.32), z: 73
      )
      # shine
      items << Circle.new(
        x: center_x - radius * 0.15, y: center_y - radius * 0.05,
        radius: radius * 0.22, color: "#FFFFFF", opacity: 0.3, z: 74
      )
      @sun_lines = nil # no rotating rays for banana

    # ── ☀️ Güneş (fallback / ileride kullanılabilir) ─────────────
    when :sun
      8.times do |i|
        angle = i * (Math::PI / 4)
        x1 = center_x + Math.cos(angle) * (radius * 1.35)
        y1 = center_y + Math.sin(angle) * (radius * 1.35)
        x2 = center_x + Math.cos(angle) * (radius * 1.95)
        y2 = center_y + Math.sin(angle) * (radius * 1.95)
        items << Line.new(
          x1: x1, y1: y1,
          x2: x2, y2: y2,
          width: 10,
          color: ColorUtils.lighten(hex, 0.25),
          z: 71,
          opacity: 0.95
        )
      end
      items << Circle.new(x: center_x, y: center_y, radius: radius, color: hex, z: 72)
      items << Circle.new(
        x: center_x - radius * 0.25, y: center_y - radius * 0.22,
        radius: radius * 0.36, color: "#FFFFFF", opacity: 0.3, z: 73
      )
      @sun_lines = items.first(8) # enable rotating ray animation
      @sun_center_x = center_x
      @sun_center_y = center_y
      @sun_radius    = radius
      @sun_phase     = 0.0

    # ── 🍃 Yaprak ─────────────────────────────────────────────────
    when :leaf
      # main oval leaf body
      items << Circle.new(x: center_x - radius * 0.12, y: center_y, radius: radius * 0.82, color: hex, z: 72)
      items << Circle.new(x: center_x + radius * 0.12, y: center_y, radius: radius * 0.82, color: hex, z: 72)
      # center vein
      items << Line.new(
        x1: center_x, y1: center_y - radius * 0.88,
        x2: center_x, y2: center_y + radius * 0.88,
        width: 4, color: ColorUtils.darken(hex, 0.3), z: 74, opacity: 0.75
      )
      # side veins
      [-1, 1].each do |side|
        3.times do |i|
          t_val = (i + 1) / 4.0
          y_off = -radius * 0.6 + radius * 1.2 * t_val
          items << Line.new(
            x1: center_x, y1: center_y + y_off,
            x2: center_x + side * radius * 0.5, y2: center_y + y_off - radius * 0.18,
            width: 2, color: ColorUtils.darken(hex, 0.25), z: 74, opacity: 0.6
          )
        end
      end
      # shine
      items << Circle.new(
        x: center_x - radius * 0.3, y: center_y - radius * 0.25,
        radius: radius * 0.35, color: "#FFFFFF", opacity: 0.22, z: 75
      )

    # ── 🥕 Havuç ─────────────────────────────────────────────────
    when :carrot
      # carrot triangle body
      items << Triangle.new(
        x1: center_x, y1: center_y + radius * 1.05,
        x2: center_x - radius * 0.65, y2: center_y - radius * 0.35,
        x3: center_x + radius * 0.65, y3: center_y - radius * 0.35,
        color: hex, z: 72
      )
      # rounded top
      items << Circle.new(x: center_x, y: center_y - radius * 0.35, radius: radius * 0.65, color: hex, z: 72)
      # texture lines
      3.times do |i|
        y_pos = center_y - radius * 0.1 + i * radius * 0.3
        w_frac = 0.55 - i * 0.12
        items << Line.new(
          x1: center_x - radius * w_frac, y1: y_pos,
          x2: center_x + radius * w_frac, y2: y_pos,
          width: 3, color: ColorUtils.darken(hex, 0.2), z: 73, opacity: 0.55
        )
      end
      # green top leaves
      3.times do |i|
        angle = -Math::PI * 0.5 + (i - 1) * 0.45
        items << Line.new(
          x1: center_x, y1: center_y - radius * 0.95,
          x2: center_x + Math.cos(angle) * radius * 0.7,
          y2: center_y - radius * 0.95 - Math.sin(angle.abs) * radius * 0.55,
          width: 5, color: "#66BB6A", z: 74, opacity: 0.95
        )
      end

    # ── 🍇 Üzüm ──────────────────────────────────────────────────
    when :grape
      # 7-grape cluster
      cluster = [
        [0, -0.52], [-0.42, -0.22], [0.42, -0.22],
        [-0.48, 0.2], [0.48, 0.2], [-0.22, 0.62], [0.22, 0.62]
      ]
      cluster.each do |dx, dy|
        gx2 = center_x + dx * radius * 1.55
        gy2 = center_y + dy * radius * 1.35
        items << Circle.new(x: gx2, y: gy2, radius: radius * 0.42, color: hex, z: 72)
        # tiny shine on each grape
        items << Circle.new(
          x: gx2 - radius * 0.14, y: gy2 - radius * 0.14,
          radius: radius * 0.12, color: "#FFFFFF", opacity: 0.4, z: 73
        )
      end
      # stem
      items << Line.new(
        x1: center_x, y1: center_y - radius * 0.84,
        x2: center_x + radius * 0.28, y2: center_y - radius * 1.18,
        width: 5, color: "#6D4C41", z: 74, opacity: 0.9
      )
      # leaf
      items << Circle.new(
        x: center_x + radius * 0.38, y: center_y - radius * 1.12,
        radius: radius * 0.22, color: "#4CAF50", z: 74, opacity: 0.9
      )

    # ── 🎈 Balon ──────────────────────────────────────────────────
    when :balloon
      # balloon body
      items << Circle.new(x: center_x, y: center_y - radius * 0.1, radius: radius, color: hex, z: 72)
      # shine reflection
      items << Circle.new(
        x: center_x - radius * 0.3, y: center_y - radius * 0.38,
        radius: radius * 0.42, color: "#FFFFFF", opacity: 0.3, z: 73
      )
      # knot at bottom
      items << Circle.new(
        x: center_x, y: center_y + radius * 0.92,
        radius: radius * 0.14, color: ColorUtils.darken(hex, 0.25), z: 74
      )
      # string
      items << Line.new(
        x1: center_x, y1: center_y + radius * 1.06,
        x2: center_x + radius * 0.18, y2: center_y + radius * 1.5,
        width: 3, color: ColorUtils.darken(hex, 0.35), z: 74, opacity: 0.8
      )
      items << Line.new(
        x1: center_x + radius * 0.18, y1: center_y + radius * 1.5,
        x2: center_x - radius * 0.1, y2: center_y + radius * 1.88,
        width: 3, color: ColorUtils.darken(hex, 0.35), z: 74, opacity: 0.8
      )

    # ── 🍄 Kozalak / Kahverengi ───────────────────────────────────
    when :pinecone
      # layered scales from bottom to top
      7.times do |i|
        t_val = i / 6.0
        y_top = center_y + radius * (0.8 - t_val * 1.55)
        w_half = radius * (0.75 - t_val * 0.42)
        shade = ColorUtils.darken(hex, 0.05 + (1.0 - t_val) * 0.2)
        items << Triangle.new(
          x1: center_x, y1: y_top - radius * 0.38,
          x2: center_x - w_half, y2: y_top,
          x3: center_x + w_half, y3: y_top,
          color: shade, z: 72, opacity: 0.94
        )
      end
      # top tip
      items << Circle.new(x: center_x, y: center_y - radius * 0.82, radius: radius * 0.16, color: ColorUtils.darken(hex, 0.35), z: 74)

    # ── 🪨 Taş / Siyah ────────────────────────────────────────────
    when :stone, :rock
      # main boulder
      items << Circle.new(x: center_x, y: center_y, radius: radius, color: hex, z: 72)
      # second smaller rock behind
      items << Circle.new(
        x: center_x + radius * 0.65, y: center_y + radius * 0.2,
        radius: radius * 0.55, color: ColorUtils.lighten(hex, 0.06), z: 71
      )
      # shine
      items << Circle.new(
        x: center_x - radius * 0.28, y: center_y - radius * 0.3,
        radius: radius * 0.32, color: "#FFFFFF", opacity: 0.18, z: 73
      )
      # crack detail
      items << Line.new(
        x1: center_x - radius * 0.1, y1: center_y - radius * 0.55,
        x2: center_x + radius * 0.15, y2: center_y + radius * 0.2,
        width: 3, color: ColorUtils.darken(hex, 0.3), z: 73, opacity: 0.65
      )

    # ── ☁️ Bulut ──────────────────────────────────────────────────
    when :cloud
      cloud_color = "#FFFFFF"
      shadow_color = "#C8D8E8"
      # shadow base
      items << Circle.new(x: center_x - radius * 0.3, y: center_y + radius * 0.22, radius: radius * 0.68, color: shadow_color, z: 71, opacity: 0.5)
      items << Circle.new(x: center_x + radius * 0.32, y: center_y + radius * 0.22, radius: radius * 0.58, color: shadow_color, z: 71, opacity: 0.5)
      # cloud puffs
      items << Circle.new(x: center_x - radius * 0.55, y: center_y + radius * 0.05, radius: radius * 0.65, color: cloud_color, z: 72)
      items << Circle.new(x: center_x + radius * 0.1,  y: center_y - radius * 0.22, radius: radius * 0.72, color: cloud_color, z: 72)
      items << Circle.new(x: center_x + radius * 0.58, y: center_y + radius * 0.05, radius: radius * 0.58, color: cloud_color, z: 72)
      # base fill rectangle
      items << Rectangle.new(
        x: center_x - radius * 0.55, y: center_y + radius * 0.05,
        width: radius * 1.14, height: radius * 0.6,
        color: cloud_color, z: 72
      )
      # shine
      items << Circle.new(
        x: center_x + radius * 0.05, y: center_y - radius * 0.28,
        radius: radius * 0.28, color: "#FFFFFF", opacity: 0.6, z: 73
      )

    # ── Fallback ──────────────────────────────────────────────────
    else
      items << Circle.new(x: center_x, y: center_y, radius: radius * 0.7, color: hex, z: 72)
      items << Circle.new(
        x: center_x - radius * 0.22, y: center_y - radius * 0.22,
        radius: radius * 0.3, color: "#FFFFFF", opacity: 0.28, z: 73
      )
    end

    items
  end



  def hide_state_panels
    @selected_panel.opacity = 0.0
    @correct_panel.opacity = 0.0
    @wrong_panel.opacity = 0.0
  end

  def animate_sun_rays(dt)
    return unless @sun_lines && @sun_center_x

    @sun_phase = (@sun_phase || 0.0) + dt * GameConfig::ICON_SUN_ROTATE_SPEED
    cx = @sun_center_x
    cy = @sun_center_y
    r = @sun_radius

    @sun_lines.each_with_index do |line, i|
      next unless line.respond_to?(:x1=)

      angle = i * (Math::PI / 4) + @sun_phase
      line.x1 = cx + Math.cos(angle) * (r * 1.35)
      line.y1 = cy + Math.sin(angle) * (r * 1.35)
      line.x2 = cx + Math.cos(angle) * (r * 1.95)
      line.y2 = cy + Math.sin(angle) * (r * 1.95)
    end
  end

  def set_opacity(items, value)
    Array(items).each do |item|
      next unless item

      if item.respond_to?(:opacity=)
        item.opacity = value
      elsif item.respond_to?(:color) && item.color && item.color.respond_to?(:opacity=)
        item.color.opacity = value
      end
    end
  end
end

