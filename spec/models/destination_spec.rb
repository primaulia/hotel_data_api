require 'rails_helper'

RSpec.describe Destination, type: :model do
  describe 'validations' do
    subject(:destination) { build(:destination) }
    it { should have_many(:hotels) }
  end
end
