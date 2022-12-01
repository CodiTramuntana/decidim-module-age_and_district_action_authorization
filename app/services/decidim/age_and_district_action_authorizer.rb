# frozen_string_literal: true

# Decidim does not allow to use more than one ActionAuthorization for each
# AuthorizationHandler.
# This class adds districts validation to the AgeActionAuthorization.
module Decidim

  # Allows to set a list of valid districts for
  # an authorization.
  class AgeAndDistrictActionAuthorization < ::Decidim::AgeActionAuthorization::Authorizer
    attr_reader :allowed_districts

    # Overrides the parent class method, but it still uses it to keep the base behavior
    def authorize


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# at this point we will have to check locally if the user already has a district metadata field
# if it exists, use it
# otherwise, we will have to perform a request to ask Pinbal if the+ user belongs to one of the required districts.


      # Remove the additional setting from the options hash to avoid to be considered missing.
      @allowed_districts ||= options.delete("allowed_districts")&.split(/[\W,;]+/)

      status_code, data = *super

      extra_explanations = []
      if allowed_districts.present?
        # Does not authorize users in different districts
        status_code = :unauthorized if status_code == :ok && disallowed_user_districts

        # Adds an extra message for inform the user the additional restriction for this authorization
        if disallowed_user_districts
          if user_district
            i18n_districts_key = "extra_explanation.user_districts"
            user_district_params = { user_district: }
          else
            i18n_districts_key = "extra_explanation.districts"
            user_district_params = {}
          end

          extra_explanations << { key: i18n_districts_key,
                                  params: { count: allowed_districts.count,
                                            districts: allowed_districts.join(", ") }.merge(user_district_params) }
        end
      end

      data[:extra_explanation] = extra_explanations if extra_explanations.any?

      [status_code, data]
    end

    # Adds the list of allowed districts to the redirect URL, to allow forms to inform about it
    def redirect_params
      { districts: allowed_districts&.join(",") }.merge(user_metadata_params)
    end

    private

    def user_district
      @user_district ||= authorization.metadata["postal_code"] if authorization && authorization.metadata
    end

    def disallowed_user_districts
      return unless user_district || allowed_districts.present?

      !allowed_districts.member?(user_district)
    end

    def user_metadata_params
      return {} unless authorization

      @user_metadata_params ||= begin
        user_metadata_params = {}
        user_metadata_params[:user_district] = authorization.metadata["postal_code"] if authorization.metadata["postal_code"].present?

        user_metadata_params
      end
###########################################
      def missing_fields
        @missing_fields ||= (valid_metadata? ? [] : [:birthdate])
      end

      def unmatched_fields
        @unmatched_fields ||= set_unmatched_fields
      end

      private

      def set_unmatched_fields
        errors = []
        errors << :birthdate unless valid_age?
        errors
      end

      def valid_metadata?
        return unless authorization

        !authorization.metadata["birthdate"].nil?
      end

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

      def birthdate
        @birthdate ||= Date.strptime(authorization.metadata["birthdate"], "%Y/%m/%d")
      end

      def minimum_age
        @minimum_age ||= begin
                           Integer(options["age"].to_s, 10)
                         rescue ArgumentError
                           18
                         end
      end
    end
  end
end
