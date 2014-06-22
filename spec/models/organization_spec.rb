require 'rails_helper'

RSpec.describe Organization, :type => :model do
  describe "#import_shelter" do

    before(:each) do
      Organization.import_shelter("NY488", 10019)
    end

    it "updates only unique shelters" do
      org_count = Organization.all.count
      expect(Organization.all.count).to eql(org_count)

      Organization.import_shelter("NY488", 10019)

      expect(Organization.all.count).to eql(org_count)
    end

    after(:each) do
      Organization.delete_all
    end

  end

end
