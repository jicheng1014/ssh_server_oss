# == Schema Information
#
# Table name: system_settings
# Database name: primary
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_system_settings_on_key  (key) UNIQUE
#
require "test_helper"

class SystemSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
