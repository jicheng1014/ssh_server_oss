module ApplicationHelper
  def country_flag(country_code)
    return "" if country_code.blank?

    country_code.upcase.chars.map { |c| (c.ord + 127397).chr(Encoding::UTF_8) }.join
  end

  # 确保时间转换为东八区显示
  def time_in_beijing(time)
    return "" if time.blank?
    time.in_time_zone("Asia/Shanghai")
  end
end
