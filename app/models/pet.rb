require 'nokogiri'
require 'open-uri'
require 'digest'

class Pet
  include Mongoid::Document
  field :organization_id, type: Integer
  field :petfinder_id, type: Integer
  field :shelter_id, type: String
  field :shelter_pet_id, type: String
  field :pet_type, type: String
  field :name, type: String
  field :breeds, type: String
  field :mix, type: Boolean
  field :age, type: String
  field :sex, type: String
  field :size, type: String
  field :has_shots, type: Boolean
  field :altered, type: Boolean
  field :housetrained, type: Boolean
  field :description, type: String
  field :last_update, type: Date
  field :status, type: String
  field :created_at, type: Date

  belongs_to :organization, inverse_of: :pets

  validates_presence_of :organization_id
  validates_presence_of :petfinder_id
  validates_presence_of :shelter_id

  KEY = "4c998baa8bbb5498a272063861be77e9"

  def self.get_pets(org_id, count)
    uri = URI.parse "http://api.petfinder.com/shelter.getPets?key=#{KEY}&id=#{org_id}&count=#{count}"
    response = uri.read
    return Nokogiri::XML(response)
  end

  def self.import(org_id, count=100)
    saved_count = 0
    cat_count = 0
    dog_count = 0

    doc = Pet.get_pets(org_id, count)

    pets = doc.xpath("//pet")

    
    contact = pets.first.xpath("contact")
    zip = contact.xpath("zip").text.strip
    Organization.import_shelter(org_id, zip)
    org = Organization.find_by(shelter_id: org_id)

    pets.each do |pet|
      unless Pet.find_by(petfinder_id: pet.xpath("id").text)
        while saved_count < count.to_i 
          if %w{ cat dog }.include?pet.xpath("animal").text.strip.downcase
            options = pet.xpath("options/option")
            Pet.create!(
              organization_id: org.id,
              petfinder_id: pet.xpath("id").text,
              shelter_id: pet.xpath("shelterId").text,
              shelter_pet_id: pet.xpath("shelterPetId").text.strip,
              pet_type: pet.xpath("animal").text.strip.downcase,
              name: pet.xpath("name").text.strip,
              breeds: pet.xpath("breeds").text.strip,
              mix: (pet.xpath("mix").text == "yes" ? true : false),
              age: pet.xpath("age").text.strip,
              sex: pet.xpath("sex").text.strip,
              size: pet.xpath("size").text.strip,
              has_shots: options.select{|o| o.text == "hasShots"}.present?,
              altered: options.select{|o| o.text == "altered"}.present?,
              housetrained: options.select{|o| o.text == "housetrained"}.present?,
              description: pet.xpath("description").text.strip,
              last_update: pet.xpath("lastUpdate").text.to_time,
              status: pet.xpath("status").text.strip,
              created_at: Time.now
            )
            saved_count += 1
            cat_count += 1 if Pet.last.pet_type == "cat"
            dog_count += 1 if Pet.last.pet_type == "dog"
          end
        end
      end
    end
    puts "Imported #{cat_count} new cats and #{dog_count} new dogs out of #{saved_count} animals."
  end

end
