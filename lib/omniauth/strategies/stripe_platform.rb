require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripePlatform < OmniAuth::Strategies::OAuth2
      option :name, 'stripe_platform'

      option :client_options, {
        :site => 'https://manage.stripe.com'
      }

      uid { raw_info[:stripe_user_id] }

      info do
        {
          :scope => raw_info[:scope],
          :livemode => raw_info[:livemode],
          :stripe_publishable_key => raw_info[:stripe_publishable_key]
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.params)
      end

      def build_access_token
        headers = {
          :headers => {
            'Authorization' => "Bearer #{client.secret}"
          }
        }
        verifier = request.params['code']
        client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)).merge(headers))
      end
    end
  end
end
