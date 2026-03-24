module CollisionUtils
  module_function

  def point_in_rect?(x, y, rect)
    return false if rect.nil?

    rx = rect[:x]
    ry = rect[:y]
    rw = rect[:width]
    rh = rect[:height]

    return false if rx.nil? || ry.nil? || rw.nil? || rh.nil?

    x >= rx && x <= (rx + rw) && y >= ry && y <= (ry + rh)
  end
end

