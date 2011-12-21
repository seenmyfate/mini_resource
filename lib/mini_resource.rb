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
    return response[method_name] if has_key?(method_name)
    super
  end

  def attributes
    response.keys
  end
 
  private

  def has_key?(method_name)
    response.has_key?(method_name)
  end

  module ClassMethods
    attr_accessor :uri

    def find(id)
      new MiniResource::Request.new(uri,id)
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
      @uri = URI.parse([url,id].join)
      @response = Response.new(get)
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
    require 'active_support/core_ext/hash/indifferent_access'
     attr_accessor :parsed_response
    def initialize(json)
      @parsed_response = ActiveSupport::JSON.decode(json).symbolize_keys!
    end
  end
end


