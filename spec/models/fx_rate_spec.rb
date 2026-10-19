require "rails_helper"

RSpec.describe FxRate, type: :model do
  subject { build(:fx_rate) }

  it { is_expected.to validate_presence_of(:currency) }
  it { is_expected.to validate_uniqueness_of(:currency).case_insensitive }
  it { is_expected.to validate_numericality_of(:rate_to_usd).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:as_of) }
end
