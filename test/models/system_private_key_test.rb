# == Schema Information
#
# Table name: system_private_keys
# Database name: primary
#
#  id          :integer          not null, primary key
#  private_key :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class SystemPrivateKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
