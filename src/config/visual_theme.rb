require_relative "game_config"

module VisualTheme
  module_function

  KEYS = %w[garden twilight contrast].freeze

  def normalize(key)
    k = key.to_s
    KEYS.include?(k) ? k : "garden"
  end

  def window_bg(key)
    bundle(normalize(key))[:window_bg]
  end

  def bundle(key)
    case normalize(key)
    when "twilight"
      theme_twilight
    when "contrast"
      theme_contrast
    else
      theme_garden
    end
  end

  def theme_garden
    gx, gy = GameConfig::WINDOW_WIDTH - 165, 82
    {
      window_bg: "#2568B8",
      sun_center: [gx, gy],
      celestial: :sun,
      bloom: [
        [140, "#FFF8E1", 0.12],
        [105, "#FFECB3", 0.18],
        [78, "#FFE082", 0.28]
      ],
      sky_bands: [
        [0, 72, "#2568B8"],
        [72, 148, "#3D8FD9"],
        [148, 228, "#5BA7E8"],
        [228, 318, "#6EB8F0"],
        [318, 402, "#8ECDF7"],
        [402, 478, "#B8E0FB"]
      ],
      ray_inner: "#FFFDE7", ray_inner_op: 0.06,
      ray_outer: "#E3F2FD", ray_outer_op: 0.045,
      sun_disc_specs: [
        [78, "#FFF59D", 0.5],
        [48, "#FFD54F", 0.72],
        [36, "#FFB300", 1.0],
        [14, "#FFFDE7", 0.85]
      ],
      sun_hot_offset: [-6, -6],
      cloud_mix: "#E3F2FD",
      hills: [
        [200, 575, 280, "#558B2F", 0.55],
        [620, 590, 340, "#689F38", 0.62],
        [1020, 572, 290, "#33691E", 0.5],
        [420, 565, 380, "#7CB342", 0.45]
      ],
      grass_y: 455,
      grass_stripes_heights: [22, 24, 26, 28, 32, 36],
      grass_colors: ["#7CB342", "#8BC34A", "#9CCC65", "#AED581", "#C5E1A5", "#DCEDC8"],
      grass_last: "#E8F5E0",
      horizon: ["#A5D6A7", 0.55],
      grass_blade_mix: ["#33691E", "#7CB342"],
      flowers: [
        [178, 618, "#F48FB1", "#F50057"], [238, 642, "#FFF176", "#F9A825"], [318, 612, "#FFAB91", "#E64A19"],
        [978, 626, "#CE93D8", "#6A1B9A"], [1048, 652, "#EF9A9A", "#C62828"], [148, 592, "#E1BEE7", "#8E24AA"],
        [1118, 604, "#F8BBD0", "#AD1457"], [858, 634, "#FFE082", "#FF8F00"], [640, 648, "#80DEEA", "#00838F"],
        [480, 628, "#A5D6A7", "#2E7D32"], [900, 598, "#FFCC80", "#EF6C00"]
      ],
      sparkles: ["#FFFDE7", "#FFFFFF", "#E1F5FE", "#FFECB3", "#F1F8E9"],
      vignette: ["#1A237E", 0.08]
    }
  end

  def theme_twilight
    gx, gy = GameConfig::WINDOW_WIDTH - 155, 78
    grass_y = 455
    {
      window_bg: "#1A237E",
      sun_center: [gx, gy],
      celestial: :moon,
      bloom: [
        [120, "#E8EAF6", 0.14],
        [88, "#C5CAE9", 0.22],
        [58, "#9FA8DA", 0.32]
      ],
      sky_bands: [
        [0, 90, "#12005E"],
        [90, 185, "#311B92"],
        [185, 280, "#4527A0"],
        [280, 370, "#5E35B1"],
        [370, 455, "#7E57C2"],
        [455, 478, "#9575CD"]
      ],
      ray_inner: "#EDE7F6", ray_inner_op: 0.05,
      ray_outer: "#B39DDB", ray_outer_op: 0.04,
      sun_disc_specs: [
        [72, "#E8EAF6", 0.45],
        [44, "#F5F5F5", 0.78],
        [28, "#FFFFFF", 0.95],
        [10, "#FFFDE7", 0.75]
      ],
      sun_hot_offset: [-5, -5],
      cloud_mix: "#D1C4E9",
      hills: [
        [180, 578, 260, "#1B5E20", 0.42],
        [600, 592, 320, "#2E7D32", 0.48],
        [1000, 575, 270, "#1B3D0A", 0.38],
        [400, 568, 360, "#33691E", 0.4]
      ],
      grass_y: grass_y,
      grass_stripes_heights: [22, 24, 26, 28, 32, 36],
      grass_colors: ["#33691E", "#3E5F1F", "#4A6620", "#558B2F", "#689F38", "#7CB342"],
      grass_last: "#9CCC65",
      horizon: ["#66BB6A", 0.45],
      grass_blade_mix: ["#1B5E20", "#558B2F"],
      flowers: [
        [178, 618, "#CE93D8", "#6A1B9A"], [238, 642, "#FFEE58", "#F9A825"],
        [318, 612, "#F48FB1", "#C2185B"], [978, 626, "#B39DDB", "#4527A0"],
        [1048, 652, "#FFAB91", "#D84315"], [148, 592, "#E1BEE7", "#6A1B9A"],
        [1118, 604, "#EA80FC", "#AA00FF"], [858, 634, "#FFF59D", "#F57F17"],
        [640, 648, "#80DEEA", "#006064"], [480, 628, "#A5D6A7", "#1B5E20"],
        [900, 598, "#FFCC80", "#E65100"]
      ],
      sparkles: ["#FFF9C4", "#E1F5FE", "#E8EAF6", "#FFECB3", "#F3E5F5"],
      vignette: ["#0D0221", 0.14]
    }
  end

  def theme_contrast
    gx, gy = GameConfig::WINDOW_WIDTH - 168, 84
    grass_y = 452
    {
      window_bg: "#0D47A1",
      sun_center: [gx, gy],
      celestial: :sun,
      bloom: [
        [130, "#FFEB3B", 0.18],
        [95, "#FFF176", 0.28],
        [68, "#FFD54F", 0.38]
      ],
      sky_bands: [
        [0, 100, "#01579B"],
        [100, 220, "#0277BD"],
        [220, 340, "#0288D1"],
        [340, 455, "#039BE5"],
        [455, 478, "#4FC3F7"]
      ],
      ray_inner: "#FFFFFF", ray_inner_op: 0.08,
      ray_outer: "#B3E5FC", ray_outer_op: 0.055,
      sun_disc_specs: [
        [80, "#FFEB3B", 0.55],
        [50, "#FFC107", 0.85],
        [34, "#FF6F00", 1.0],
        [12, "#FFFFFF", 0.95]
      ],
      sun_hot_offset: [-7, -7],
      cloud_mix: "#E1F5FE",
      hills: [
        [200, 575, 280, "#1B5E20", 0.75],
        [620, 590, 340, "#2E7D32", 0.78],
        [1020, 572, 290, "#004D40", 0.72],
        [420, 565, 380, "#33691E", 0.7]
      ],
      grass_y: grass_y,
      grass_stripes_heights: [24, 26, 28, 30, 34, 38],
      grass_colors: ["#1B5E20", "#2E7D32", "#388E3C", "#43A047", "#558B2F", "#689F38"],
      grass_last: "#AED581",
      horizon: ["#00C853", 0.65],
      grass_blade_mix: ["#000000", "#76FF03"],
      flowers: [
        [178, 618, "#FF1744", "#B71C1C"], [238, 642, "#FFEA00", "#F57F17"],
        [318, 612, "#2979FF", "#0D47A1"], [978, 626, "#D500F9", "#4A148C"],
        [1048, 652, "#FF3D00", "#BF360C"], [148, 592, "#00E676", "#1B5E20"],
        [1118, 604, "#FF4081", "#880E4F"], [858, 634, "#FFEA00", "#F57F17"],
        [640, 648, "#00B0FF", "#01579B"], [480, 628, "#76FF03", "#33691E"],
        [900, 598, "#FF9100", "#E65100"]
      ],
      sparkles: ["#FFFFFF", "#FFFF00", "#00E5FF", "#76FF03", "#FF4081"],
      vignette: ["#000000", 0.12]
    }
  end
end
