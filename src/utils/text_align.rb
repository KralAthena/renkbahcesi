module TextAlign
  module_function

  def text_metrics(text_obj)
    return [nil, nil] unless text_obj

    w = text_obj.instance_variable_get(:@width)
    h = text_obj.instance_variable_get(:@height)
    [w, h]
  end

  def center_horizontally(text_obj, window_width)
    return unless text_obj

    w, = text_metrics(text_obj)
    return unless w && w.to_f.positive?

    text_obj.x = (window_width - w.to_f) / 2.0
  end

  def center_horizontally_in(text_obj, left, segment_width)
    return unless text_obj

    w, = text_metrics(text_obj)
    return unless w && w.to_f.positive?

    text_obj.x = left.to_f + (segment_width.to_f - w.to_f) / 2.0
  end

  def center_in_rect(text_obj, left, top, width, height)
    return unless text_obj

    tw, th = text_metrics(text_obj)
    return unless tw && th && tw.to_f.positive? && th.to_f.positive?

    text_obj.x = left.to_f + (width.to_f - tw.to_f) / 2.0
    text_obj.y = top.to_f + (height.to_f - th.to_f) / 2.0
  end
end
