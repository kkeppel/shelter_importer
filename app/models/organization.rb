require 'nokogiri'
require 'open-uri'
require 'digest'

class Organization
  include Mongoid::Document
  field :name, type: String
  field :shelter_id, type: String
  field :created_at, type: Date
  field :address1, type: String
  field :address2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :country, type: String
  field :latitude, type: String
  field :longitude, type: String
  field :phone, type: String
  field :fax, type: String
  field :email, type: String

  has_many :pets, inverse_of: :organization
  accepts_nested_attributes_for :pets, :allow_destroy => true

  validates_presence_of :shelter_id
  validates_uniqueness_of :shelter_id
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create

  KEY = "4c998baa8bbb5498a272063861be77e9"

  def self.get_shelter_info(org_id, zip)
    uri = URI.parse "http://api.petfinder.com/shelter.get?key=#{KEY}&id=#{org_id}&location=#{zip}"
    response = uri.read
    return Nokogiri::XML(response)
  end

  def self.import_shelter(org_id, zip)
    doc = Organization.get_shelter_info(org_id, zip)
    shelters = doc.xpath("//shelter")

    shelter = shelters.select{|s| s.xpath("id").text == org_id}.first
    db_shelter = Organization.find_or_create_by(shelter_id: org_id)
    db_shelter.update_attributes(
      shelter_id: org_id,
      name: shelter.xpath("name").text.strip,
      address1: shelter.xpath("address1").text.strip,
      address2: shelter.xpath("address2").text.strip,
      city: shelter.xpath("city").text.strip,
      state: shelter.xpath("state").text.strip,
      country: shelter.xpath("country").text.strip,
      zip: shelter.xpath("zip").text.strip,
      latitude: shelter.xpath("latitude").text.strip,
      longitude: shelter.xpath("longitude").text.strip,
      phone: shelter.xpath("phone").text.strip,
      fax: shelter.xpath("fax").text.strip,
      email: shelter.xpath("email").text.strip,
      created_at: Time.now
    )
    db_shelter.save
  end

end
