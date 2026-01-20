module ApplicationHelper
  def country_flag(country_code)
    return "" if country_code.blank?

    country_code.upcase.chars.map { |c| (c.ord + 127397).chr(Encoding::UTF_8) }.join
  end
end
