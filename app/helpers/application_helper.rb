module ApplicationHelper
  def ascii_to_string(ascii)
    case ascii
    when 33..126
      ascii.chr
    when 32
      '\u2423'
    when 127
      'blank'
    else
      'error'
    end
  end
  def ascii_to_symbol(ascii)
    case ascii
    when 33..126
      ascii.chr
    when 32
      '\u2423'
    else
      ''
    end
  end
  def ascii_to_shift(ascii)
    if ascii == 76
      'shift left'
    elsif ascii == 82
      'shift right'
    else
      'stand still'
    end
  end
end
