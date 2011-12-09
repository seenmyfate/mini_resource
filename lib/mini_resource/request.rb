module MiniResource
  class Request
    require 'net/http'
    require 'uri'
    require 'json'

    attr_accessor :url, :response

    def initialize(url,id)
      @uri = URI.parse([url,id].join)
      @response = Response.new(get)
    end

    class ApiError < Exception
      def message

      end
    end

    class ResourceNotFound < Exception
      def message

      end
    end

    private

    def get
      response = http.request(request)
      raise ApiError unless response.code.to_i == 200
      response.body
    end

    def http
      Net::HTTP.new(uri.host, port)
    end

    def request
      Net::HTTP::Get.new(uri.request_uri)
    end
  end
end
