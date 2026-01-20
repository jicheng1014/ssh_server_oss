# == Schema Information
#
# Table name: server_metrics
# Database name: primary
#
#  id           :integer          not null, primary key
#  cpu_cores    :integer
#  cpu_usage    :float
#  disk_total   :float
#  disk_usage   :float
#  memory_total :float
#  memory_usage :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  server_id    :integer          not null
#
# Indexes
#
#  index_server_metrics_on_server_id  (server_id)
#
# Foreign Keys
#
#  server_id  (server_id => servers.id)
#
require "test_helper"

class ServerMetricTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
