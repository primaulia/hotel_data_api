require 'rails_helper'

RSpec.describe BookingCondition, type: :model do
  describe 'validations' do
    subject(:booking_condition) { build(:booking_condition) }

    it { should validate_presence_of(:condition) }
    it { should belong_to(:hotel) }
  end
end
