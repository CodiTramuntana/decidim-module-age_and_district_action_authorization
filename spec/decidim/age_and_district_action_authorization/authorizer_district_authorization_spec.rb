# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::AgeAndDistrictActionAuthorization::Authorizer do
  let(:authorizer_class) { Decidim::AgeAndDistrictActionAuthorization::Authorizer }
  let(:component) { double("component") }
  let(:resource) { double("resource", component: true) }

  context "when allowing a single district" do
    it "authorizes when district metadata match" do
      authorizer = authorizer_class.new(authorization_for("17600"), { "allowed_districts" => "17600" }, component, resource)
      expect(authorizer.authorize).to include(:ok)
    end

    it "does not authorize when district metadata unmatch" do
      authorizer = authorizer_class.new(authorization_for("17600"), { "allowed_districts" => "16700" }, component, resource)
      expect(authorizer.authorize).to include(:unauthorized)
    end
  end

  context "when allowing a list of districts" do
    it "authorizes with district metadata" do
      authorizer = authorizer_class.new(authorization_for("17600"), { "allowed_districts" => ["17600", "17740"] }, component, resource)
      expect(authorizer.authorize).to include(:ok)
    end

    it "does not authorize when district metadata unmatch" do
      authorizer = authorizer_class.new(authorization_for("17600"), { "allowed_districts" => ["08080", "99999"] }, component, resource)
      expect(authorizer.authorize).to include(:unauthorized)
    end
  end

  context "when no district is set" do
    it "authorizes with any district metadata" do
      authorizer = authorizer_class.new(authorization_for(""), {}, component, resource)
      expect(authorizer.authorize).to include(:ok)
      authorizer = authorizer_class.new(authorization_for("12345"), {}, component, resource)
      expect(authorizer.authorize).to include(:ok)
    end
  end

  it "does not authorize the user if districts are defined but the authorization is not present" do
    authorizer_without_authorization = authorizer_class.new(nil, { "allowed_districts" => ["17600"] }, component, resource)

    expect(authorizer_without_authorization.authorize).to include(:missing)
  end

  it "does not authorize the user if districts are defined but the metadata is empty" do
    authorizer_without_authorization = authorizer_class.new(authorization_for(""), { "allowed_districts" => ["17600", "00671"] }, component, resource)

    expect(authorizer_without_authorization.authorize).to include(:unauthorized)
  end

  # Returns an Authorization object
  def authorization_for(district)
    OpenStruct.new(metadata: { "district" => district, "birthdate" => "1970/11/21" },
                   granted?: true)
  end
end
