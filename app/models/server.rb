# == Schema Information
#
# Table name: servers
# Database name: primary
#
#  id              :integer          not null, primary key
#  active          :boolean          default(TRUE)
#  country_code    :string
#  host            :string           not null
#  kernel_version  :string
#  last_checked_at :datetime
#  last_error      :text
#  name            :string           not null
#  os_name         :string
#  os_version      :string
#  password        :text
#  port            :integer          default(22)
#  position        :integer          default(0), not null
#  private_key     :text
#  provider        :string
#  username        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_servers_on_host  (host) UNIQUE
#
class Server < ApplicationRecord
  PROVIDERS = %w[AWS Bandwagon Aliyun Tencent].freeze

  has_many :server_metrics, dependent: :destroy
  has_rich_text :notes

  # 使用 Active Record Encryption 加密敏感字段
  encrypts :password, :private_key

  validates :name, presence: true
  validates :host, presence: true, uniqueness: true
  validates :username, presence: true
  validates :port, numericality: { only_integer: true, greater_than: 0, less_than: 65536 }

  before_save :lookup_country_code, if: :host_changed?

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }

  def latest_metric
    server_metrics.order(created_at: :desc).first
  end

  def country_flag
    return nil if country_code.blank?

    # Convert country code to flag emoji (e.g., "US" -> 🇺🇸)
    country_code.upcase.chars.map { |c| (c.ord + 127397).chr(Encoding::UTF_8) }.join
  end

  def masked_host
    parts = host.split(".")
    return host if parts.length < 2

    if parts.length == 4 && parts.all? { |p| p.match?(/^\d+$/) }
      # IP address: 192.168.1.100 -> 192.*.*. 100
      "#{parts.first}.*.*.#{parts.last}"
    else
      # Domain: example.com -> e***e.com or sub.example.com -> s***b.example.com
      first_part = parts.first
      masked_first = first_part.length > 2 ? "#{first_part[0]}***#{first_part[-1]}" : first_part
      "#{masked_first}.#{parts[1..-1].join('.')}"
    end
  end

  # 获取认证信息，优先级：服务器私钥 > 服务器密码 > 全局私钥
  def authentication_options
    if private_key.present?
      { key_data: [private_key] }
    elsif password.present?
      { password: password }
    else
      global_key = SshKeyService.private_key
      if global_key.present?
        { key_data: [global_key] }
      else
        {}
      end
    end
  end

  def has_authentication?
    private_key.present? || password.present? || SshKeyService.configured?
  end

  private

  def lookup_country_code
    self.country_code = IpLocationService.new(host).call
  end
end
