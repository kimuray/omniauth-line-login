require "omniauth/strategies/oauth2"
require "jwt"

module OmniAuth
  module Strategies
    class LineLogin < OmniAuth::Strategies::OAuth2
      USER_INFO_URL = "https://api.line.me/v2/profile"
      API_URL = "https://api.line.me"

      option :name, "line_login"
      option :authorize_option, %i[scope prompt bot_prompt]

      option :client_options, {
        site: "https://access.line.me",
        authorize_url: "/oauth2/v2.1/authorize",
        token_url: "/oauth2/v2.1/token"
      }

      uid { raw_info['userId'] }

      attr_accessor :id_token

      def callback_phase
        options[:client_options][:site] = API_URL
        error = request.params["error_reason"] || request.params["error"]
        if error
          fail!(error, CallbackError.new(request.params["error"], request.params["error_description"] || request.params["error_reason"], request.params["error_uri"]))
        elsif !options.provider_ignores_state && (request.params["state"].to_s.empty? || request.params["state"] != session.delete("omniauth.state"))
          fail!(:csrf_detected, CallbackError.new(:csrf_detected, "CSRF detected"))
        else
          self.access_token = build_access_token
          self.access_token = access_token.refresh! if access_token.expired?
          self.id_token = access_token.params["id_token"]
          env['omniauth.auth'] = auth_hash
          call_app!
        end
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def raw_info
        {}
      end
    end
  end
end