require "omniauth/strategies/oauth2"
require "jwt"

module OmniAuth
  module Strategies
    class LineLogin < OmniAuth::Strategies::OAuth2
      USER_INFO_URL = "https://api.line.me/v2/profile"

      option :name, "line_login"
      option :authorize_option, %i[scope prompt bot_prompt]

      option :client_options, {
        site: "https://access.line.me",
        authorize_url: "/oauth2/v2.1/authorize",
        token_url: "/oauth2/v2.1/token"
      }

      uid { raw_info['userId'] }

    end
  end
end