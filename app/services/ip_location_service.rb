require "net/http"
require "json"

class IpLocationService
  API_URL = "http://ip-api.com/json/"

  def initialize(ip_address)
    @ip_address = ip_address
  end

  def call
    return nil if @ip_address.blank?

    # Skip private/local IPs
    return nil if private_ip?(@ip_address)

    response = fetch_location
    return nil unless response

    response["countryCode"]
  rescue StandardError => e
    Rails.logger.error "IP location lookup failed for #{@ip_address}: #{e.message}"
    nil
  end

  private

  def fetch_location
    uri = URI("#{API_URL}#{@ip_address}?fields=countryCode")
    response = Net::HTTP.get_response(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    return nil if data["status"] == "fail"

    data
  end

  def private_ip?(ip)
    return true if ip == "localhost" || ip == "127.0.0.1"

    begin
      addr = IPAddr.new(ip)
      addr.private? || addr.loopback? || addr.link_local?
    rescue IPAddr::InvalidAddressError
      # If it's a hostname, not an IP
      false
    end
  end
end
