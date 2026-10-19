require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to have_many(:sessions).dependent(:destroy) }
  it { is_expected.to define_enum_for(:role).with_values(hr_manager: 0) }

  it "authenticates with a correct password" do
    user = create(:user, password: "password123")
    expect(user.authenticate("password123")).to eq(user)
    expect(user.authenticate("wrong")).to be_falsey
  end

  it "normalizes email to lowercase and stripped" do
    user = create(:user, email: "  HR@ACME.TEST ")
    expect(user.email).to eq("hr@acme.test")
  end

  it "rejects passwords shorter than 8 characters" do
    user = build(:user, password: "short")
    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end
end
