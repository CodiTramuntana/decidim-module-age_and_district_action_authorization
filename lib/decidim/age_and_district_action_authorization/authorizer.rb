# frozen_string_literal: true

module Decidim
  module AgeAndDistrictActionAuthorization
    class Authorizer < ::Decidim::Verifications::DefaultActionAuthorizer
      # Overrides DefaultActionAuthorizer#unmatched_fields.
      def missing_fields
        @missing_fields ||= begin
          fields= []
          if authorization
            fields << :birthdate if missing_age_in_metadata?
            fields << :district if missing_district_in_metadata?
          end
          fields
        end
      end

      def missing_age_in_metadata?
        has_age_restrictions = (%w(max_age min_age) & options.keys)
        authorization.metadata["birthdate"].blank? if has_age_restrictions
      end

      def missing_district_in_metadata?
        has_district_restrictions = options.keys.include?("allowed_districts")
        authorization.metadata["district"].blank? if has_district_restrictions
      end

      # Checks if the restrictions defined in the permissions are being matched or not.
      # Overrides DefaultActionAuthorizer#unmatched_fields.
      def unmatched_fields
        @unmatched_fields ||= begin
          errors = []
          errors << :birthdate unless valid_age?
          errors << :allowed_districts unless district_match?
          errors
        end
      end

      private

      def valid_age?
        min_date = birthdate + minimum_age.years
        max_date = options["max_age"].present? &&
                   birthdate + options["max_age"].to_i.years

        if max_date
          (min_date..max_date).cover?(Date.current)
        else
          min_date <= Date.current
        end
      end

      def district_match?
        allowed= options["allowed_districts"]&.split(",")&.map { |d| d.strip }
        return true unless allowed&.present?

        user_district= authorization.metadata["district"]

        allowed.include?(user_district)
      end

      def birthdate
        @birthdate ||= Date.strptime(authorization.metadata["birthdate"], "%Y/%m/%d")
      end

      def minimum_age
        @minimum_age ||= begin
                           Integer(options["min_age"].to_s, 10)
                         rescue ArgumentError
                           18
                         end
      end
    end
  end
end
