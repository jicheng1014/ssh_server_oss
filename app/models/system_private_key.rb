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
class SystemPrivateKey < ApplicationRecord
  # 使用 Active Record Encryption 加密私钥字段
  encrypts :private_key

  # 确保只有一条记录（单例模式）
  before_create :ensure_single_record

  def self.first_or_initialize
    record = first
    record ||= new
    record
  end

  private

  def ensure_single_record
    if SystemPrivateKey.exists?
      errors.add(:base, "只能存在一条系统私钥记录")
      throw(:abort)
    end
  end
end
