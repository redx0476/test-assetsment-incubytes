require "rails_helper"

RSpec.describe PayBand, type: :model do
  subject { build(:pay_band) }

  it { is_expected.to validate_presence_of(:country_code) }

  it "requires a unique job level per country" do
    create(:pay_band, job_level: :mid, country_code: "US")
    duplicate = build(:pay_band, job_level: :mid, country_code: "US")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:job_level]).to be_present
  end

  it "rejects bounds that are not ordered min <= mid <= max" do
    band = build(:pay_band, min_cents: 10, mid_cents: 5, max_cents: 20)
    expect(band).not_to be_valid
    expect(band.errors[:base].join).to match(/min <= mid <= max/)
  end

  describe ".for" do
    it "finds the band by level and country" do
      band = create(:pay_band, job_level: :senior, country_code: "GB")
      expect(PayBand.for(job_level: :senior, country_code: "GB")).to eq(band)
    end
  end
end
