module MiniResource
  attr_accessor :uri

  def find(id)
    Request.new(uri,id).response
  end

  class Request
    require 'net/http'
    require 'uri'
    require 'json'

    attr_accessor :uri, :response

    def initialize(url,id)
      @uri = URI.parse([url,id].join)
      @response = JSON.parse(get)
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
      Net::HTTP.new(uri.host, uri.port)
    end

    def request
      Net::HTTP::Get.new(uri.to_s)
    end
  end
end


