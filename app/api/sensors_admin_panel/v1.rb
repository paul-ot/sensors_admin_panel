require 'grape-swagger'

module SensorsAdminPanel
  class V1 < Grape::API
    version 'v1', using: :path, vendor: 'sensors_admin_panel'
    # Specific content type to set UTF-8 and avoid codification problems
    content_type :json, 'application/json; charset=UTF-8'
    prefix :api
    format :json

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    helpers do
      def api_response response
        case response
        when Integer
          status response
        when String
          response
        when Hash
          response
        when Net::HTTPResponse
          "#{response.code}: #{response.message}"
        else
          status 400 # Bad request
        end
      end

      def authenticate!
        error!('Unauthorized. Invalid or expired token.', 401) unless current_user
      end

      def clean_params(params)
        ActionController::Parameters.new(params)
      end

      def current_user
        # Find token. Check if valid.
        token = ::ApiKey.where(access_token: params[:token]).first
        if token && !token.expired?
          @current_user = ::User.find(token.user_id)
        else
          false
        end
      end
    end

    mount Sensor

    add_swagger_documentation(
      api_version: "v1",
      hide_documentation_path: true,
      hide_format: true,
      markdown: GrapeSwagger::Markdown::RedcarpetAdapter
                .new(render_options: { highlighter: :rouge })
    )

  end
end