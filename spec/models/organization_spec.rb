require 'rails_helper'

RSpec.describe Organization, :type => :model do
  describe "#import_shelter" do

    before(:each) do
      Organization.import_shelter("NY488", 10019)
    end

    it "updates only unique shelters" do
      expect(Organization.all.count).to eql(1)

      Organization.import_shelter("NY488", 10019)
      expect(Organization.all.count).to eql(1)
    end

  end

  after(:each) do
    Organization.delete_all
  end
  
end
