class Panel
  attr_reader :x, :y, :width, :height, :radius, :border_width, :fill_color, :border_color, :primitives

  def initialize(x:, y:, width:, height:, radius:, fill_color:, border_color:, border_width:, opacity: 1.0, z: 1)
    @x = x.to_f
    @y = y.to_f
    @width = width.to_f
    @height = height.to_f
    @radius = radius.to_f
    @border_width = border_width.to_f
    @fill_color = fill_color
    @border_color = border_color
    @opacity = opacity.to_f
    @z = z

    @primitives = []
    build
  end

  def contains_point?(px, py)
    px >= @x && px <= (@x + @width) && py >= @y && py <= (@y + @height)
  end

  def opacity=(value)
    @opacity = value.to_f
    @primitives.each do |p|
      if p.respond_to?(:opacity=)
        p.opacity = @opacity
      elsif p.respond_to?(:color) && p.color && p.color.respond_to?(:opacity=)
        p.color.opacity = @opacity
      end
    end
  end

  def remove
    @primitives.each { |p| p.remove if p.respond_to?(:remove) }
    @primitives.clear
  end

  private

  def build
    outer_radius = [@radius, @width / 2.0, @height / 2.0].min
    inner_radius = [outer_radius - @border_width, 0].max

    outer = build_filled_round_rect(
      x: @x,
      y: @y,
      width: @width,
      height: @height,
      radius: outer_radius,
      color: @border_color,
      z: @z,
      opacity: @opacity
    )

    inner_x = @x + @border_width
    inner_y = @y + @border_width
    inner_w = [@width - 2.0 * @border_width, 0].max
    inner_h = [@height - 2.0 * @border_width, 0].max

    inner = build_filled_round_rect(
      x: inner_x,
      y: inner_y,
      width: inner_w,
      height: inner_h,
      radius: inner_radius,
      color: @fill_color,
      z: @z + 0.1,
      opacity: @opacity
    )

    @primitives.concat(outer)
    @primitives.concat(inner)
  end

  def build_filled_round_rect(x:, y:, width:, height:, radius:, color:, z:, opacity:)
    radius = [radius, width / 2.0, height / 2.0].min

    primitives = []

    center_w = [width - 2.0 * radius, 0].max
    center_h = [height - 2.0 * radius, 0].max
    primitives << Rectangle.new(
      x: x + radius, y: y + radius,
      width: center_w, height: center_h,
      color: color, z: z, opacity: opacity
    ) if center_w.positive? && center_h.positive?

    top_h = radius
    bottom_h = radius
    left_w = radius
    right_w = radius

    mid_w = [width - 2.0 * radius, 0].max
    mid_h = [height - 2.0 * radius, 0].max

    primitives << Rectangle.new(
      x: x + radius, y: y,
      width: mid_w, height: top_h,
      color: color, z: z, opacity: opacity
    ) if mid_w.positive? && top_h.positive?

    primitives << Rectangle.new(
      x: x + radius, y: y + height - bottom_h,
      width: mid_w, height: bottom_h,
      color: color, z: z, opacity: opacity
    ) if mid_w.positive? && bottom_h.positive?

    primitives << Rectangle.new(
      x: x, y: y + radius,
      width: left_w, height: mid_h,
      color: color, z: z, opacity: opacity
    ) if left_w.positive? && mid_h.positive?

    primitives << Rectangle.new(
      x: x + width - right_w, y: y + radius,
      width: right_w, height: mid_h,
      color: color, z: z, opacity: opacity
    ) if right_w.positive? && mid_h.positive?

    primitives << Circle.new(
      x: x + radius, y: y + radius,
      radius: radius,
      color: color, z: z + 0.05, opacity: opacity
    ) if radius.positive?

    primitives << Circle.new(
      x: x + width - radius, y: y + radius,
      radius: radius,
      color: color, z: z + 0.05, opacity: opacity
    ) if radius.positive?

    primitives << Circle.new(
      x: x + radius, y: y + height - radius,
      radius: radius,
      color: color, z: z + 0.05, opacity: opacity
    ) if radius.positive?

    primitives << Circle.new(
      x: x + width - radius, y: y + height - radius,
      radius: radius,
      color: color, z: z + 0.05, opacity: opacity
    ) if radius.positive?

    primitives
  end
end

