module MiniResource
  require 'mini_resource/core_ext/hash'
  def self.included(base)
    base.send(:attr_accessor, :response)
    base.extend(ClassMethods)
  end

  def initialize(response={})
    @response = response
    super
  end

  def respond_to?(method_name, include_private=nil)
    return true if response.has_key?(method_name)
    super
  end
 
  def method_missing(method_name, *args, &blk)
    return response[method_name] if response.has_key?(method_name)
    super
  end

  module ClassMethods
    attr_accessor :uri

    def find(id)
      new MiniResource::Request.new(uri,id).response
    end
  end

  #
  # Handle the request, get the response
  #
  class Request
    require 'net/https'
    require 'uri'
    attr_accessor :uri, :response

    def initialize(url,id)
      @uri = URI.parse([url,id, format].join)
      @response = Response.new(get).parsed_response
    end

    #
    # Raised if the net/http response is not 200 or 404
    #
    class ApiError < Exception;end;

    #
    # Raise if the net/http response is 404
    #
    class ResourceNotFound < Exception;end;

    private

    def format
      '.json'
    end

    def get
      response = http.request(request)
      case response.code.to_i
      when 200 then response.body
      when 404 then raise ResourceNotFound
      else
        raise ApiError
      end
    end

    def host
      uri.host
    end

    def port
      uri.port
    end

    def http
      Net::HTTP.new(host, port)
    end

    def request
      Net::HTTP::Get.new(uri.to_s)
    end
  end

  #
  # Handle parsing
  #
  class Response
    require 'active_support/json'
     attr_accessor :parsed_response, :response
    def initialize(json)
      @response = json
      @parsed_response = parse_response 
    end

    def parse_response
      hash = ActiveSupport::JSON.decode(response).deep_symbolize_keys
      hash[:hotel]
    end
  end
end


