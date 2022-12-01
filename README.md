# Decidim::AgeAndDistrictActionAuthorization

A Decidim based action authorizer to check user's age and/or district inside actions.

This module is based on the `decidim-age_action_authorization` module in https://github.com/diputacioBCN/decidim-diba. Decidim's
[Default Action Authorizer](https://github.com/decidim/decidim/blob/5e5377b4dbb7bfb73f916d7d0a7c41014ac1960f/decidim-verifications/lib/decidim/verifications/default_action_authorizer.rb) only allows comparing items that are equal to an expected value. This module extends `Decidim::Verifications::DefaultActionAuthorizer` to meet the extra age and district features.

No authorization handler is provided with this module, only an Authorizer based on `Decidim::Verifications::DefaultActionAuthorizer` that may be combined with any handler that provides the expected metadata fields.

The `Decidim::AgeAndDistrictActionAuthorization::Authorizer` checks a metadata field named _birthday_ in the  AuthorizationHandler used and compares the value against a minimum/maximum age defined in the permissions provided JSON for the action authorizer. The JSON fields are named _min_age_ and _max_age_.

E.g permission options: `{"min_age": 20 }`.

By default the minimum age is 18 years old if no JSON options are provided, so this authorization always applies once installed.

The `Decidim::AgeAndDistrictActionAuthorization::Authorizer` also checks for a metadata field named _district_ in the  AuthorizationHandler used and compares the value against a districts list defined in the provided JSON for the action authorizer. The JSON field is named _allowed_districts_.

E.g. permission options: `{"allowed_districts": 17481 }`.

Both restrictions may also be combined

E.g. permission options: `{"min_age": 10, "max_age": 25, "allowed_districts": [08080, 08081] }`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-module-age_and_district_action_authorization'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install decidim-module-age_and_district_action_authorization

## Usage

In the workflow configuration add the AgeAndDistrictActionAuthorization as the workflow's action authorizer:

```ruby
Decidim::Verifications.register_workflow(:authorization_handler) do |workflow|
  workflow.form = 'AuthorizationHandler'
  workflow.action_authorizer = 'Decidim::AgeAndDistrictActionAuthorization::Authorizer'

  options.attribute :min_age, type: :string, required: false
  options.attribute :max_age, type: :string, required: false
  options.attribute :allowed_districts, type: :string, required: false
end
```

### Run tests

Create a dummy app in your application (not in the module):

```bash
bundle exec rake decidim:generate_external_test_app
```

And run tests from the module:

```bash
bundle exec rspec spec
```

## License

GNU AFFERO GENERAL PUBLIC LICENSE: See [LICENSE](LICENSE) file.