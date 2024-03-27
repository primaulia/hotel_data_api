require 'rails_helper'

RSpec.describe Image, type: :model do
  describe 'validations' do
    subject(:image) { build(:image) }

    it { should validate_presence_of(:link) }
    it { should validate_presence_of(:description) }
    it { should validate_uniqueness_of(:link).scoped_to(:hotel_id) }
    it { should belong_to(:hotel) }
  end
end
