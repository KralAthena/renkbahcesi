module ColorUtils
  module_function

  def hex_to_rgb(hex)
    return [0, 0, 0] if hex.nil?

    h = hex.to_s.strip
    h = h[1..] if h.start_with?("#")

    return [0, 0, 0] unless h.length == 6

    r = h[0..1].to_i(16)
    g = h[2..3].to_i(16)
    b = h[4..5].to_i(16)
    [r, g, b]
  end

  def rgb_to_hex(r, g, b)
    rr = clamp_int(r, 0, 255)
    gg = clamp_int(g, 0, 255)
    bb = clamp_int(b, 0, 255)
    format("#%02X%02X%02X", rr, gg, bb)
  end

  def mix_hex(hex_a, hex_b, ratio)
    ratio = ratio.to_f
    ratio = 0.0 if ratio.negative?
    ratio = 1.0 if ratio > 1.0

    ra, ga, ba = hex_to_rgb(hex_a)
    rb, gb, bb = hex_to_rgb(hex_b)

    r = ra + (rb - ra) * ratio
    g = ga + (gb - ga) * ratio
    b = ba + (bb - ba) * ratio
    rgb_to_hex(r, g, b)
  end

  def lighten(hex, amount)
    mix_hex(hex, "#FFFFFF", amount)
  end

  def darken(hex, amount)
    mix_hex(hex, "#000000", amount)
  end

  def tone_variation_hex(hex, strength, direction)
    strength = strength.to_f
    strength = 0.0 if strength.negative?
    strength = 1.0 if strength > 1.0

    if direction == :darken
      darken(hex, strength)
    else
      lighten(hex, strength)
    end
  end

  def clamp_int(value, min_v, max_v)
    v = value.to_f
    v = min_v if v < min_v
    v = max_v if v > max_v
    v.round
  end

  def punch_rgb(hex, strength = 0.14)
    st = strength.to_f
    st = 0.0 if st < 0.0
    st = 0.5 if st > 0.5
    r, g, b = hex_to_rgb(hex)
    avg = (r + g + b) / 3.0
    r += (r - avg) * st
    g += (g - avg) * st
    b += (b - avg) * st
    rgb_to_hex(r, g, b)
  end
end

