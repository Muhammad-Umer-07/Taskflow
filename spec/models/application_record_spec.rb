require "rails_helper"

RSpec.describe ApplicationRecord, type: :model do
  it "is the abstract base class for application models" do
    expect(described_class).to be_abstract_class
    expect(Project.superclass).to eq(described_class)
    expect(Task.superclass).to eq(described_class)
    expect(User.superclass).to eq(described_class)
    expect(ProjectMembership.superclass).to eq(described_class)
  end
end
