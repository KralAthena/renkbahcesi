class Label
  attr_reader :text_obj

  def initialize(text:, x:, y:, size:, color:, z: 10, font: nil)
    @text_obj = Ruby2D::Text.new(
      text,
      x: x,
      y: y,
      size: size,
      color: color,
      z: z
    )
    if font && @text_obj.respond_to?(:font=)
      @text_obj.font = font
    end
  end

  def text=(new_text)
    @text_obj.text = new_text.to_s
  end

  def remove
    @text_obj.remove if @text_obj.respond_to?(:remove)
  end
end

