# == Schema Information
#
# Table name: group_messages
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  message_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class GroupMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
