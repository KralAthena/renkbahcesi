class ProgressBar
  def initialize(x:, y:, width:, height:, max_value:, min_value: 0, fill_color: "#4CAF50", back_color: "#D9F7DD", z: 40)
    @x = x.to_f
    @y = y.to_f
    @width = width.to_f
    @height = height.to_f
    @max_value = [max_value.to_f, 1.0].max
    @min_value = min_value.to_f

    @back = Ruby2D::Rectangle.new(
      x: @x,
      y: @y,
      width: @width,
      height: @height,
      color: back_color,
      z: z
    )

    @fill = Ruby2D::Rectangle.new(
      x: @x,
      y: @y,
      width: @width,
      height: @height,
      color: fill_color,
      z: z + 0.1,
      opacity: 1.0
    )

    set_value(min_value)
  end

  def set_value(value)
    v = value.to_f
    v = @min_value if v < @min_value
    v = @max_value if v > @max_value

    ratio = (v - @min_value) / (@max_value - @min_value)
    ratio = 0.0 if ratio.nan?

    @fill.width = @width * ratio
  end

  def remove
    @back.remove if @back.respond_to?(:remove)
    @fill.remove if @fill.respond_to?(:remove)
  end
end

