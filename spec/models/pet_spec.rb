require 'rails_helper'

RSpec.describe Pet, :type => :model do

  describe "#import" do

    it "imports the specified count" do
      Pet.import("NY835", 10)
      expect(Pet.all.count).to eql(10)
    end

    it "only imports dogs and cats" do
      Pet.import("NY835", 10)
      expect(["cat", "dog"]).to include(Pet.all.map{|p| p.pet_type}.uniq.first)
    end

    after(:each) do
      Pet.delete_all
    end

  end

end
