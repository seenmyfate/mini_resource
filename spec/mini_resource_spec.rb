require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


class DummyClass
  include MiniResource

  def bacon
    # for testing respond_to?
  end
end

describe MiniResource do
  let(:uri) { 'http://test.com' }
  let(:id)  { 1 }
  let(:response) { {:id => 1, :name => "test" } }

  
  context "uri" do
    it 'stores the uri' do
      DummyClass.uri = uri
      DummyClass.uri.should eq uri
    end
  end

  context "#find" do
    before do
      MiniResource::Request.should_receive(:new).with(uri,id).
        and_return(response)
      DummyClass.uri = uri
    end
    subject { DummyClass.find(id) }

    it "returns a new instance" do
      subject.should be_a DummyClass
    end
  end

  context "#new" do
    
    subject { DummyClass.new(response) }
    it "stores the response" do
      subject.response.should eq response
    end
  end
  
  context "#respond_to?" do
    subject { DummyClass.new(response) }
    context "response has key" do
      it "returns true" do
        subject.respond_to?(:name).should be_true
      end
    end
    context "response does not have key" do
      it "returns false" do
        subject.respond_to?(:cheese).should be_false
      end
      context "super class defines method" do
        it "returns true" do
          subject.respond_to?(:bacon).should be_true
        end
      end
    end
  end

  context "#method_messing" do
    let(:response) { {:id => 1, :name => "test", :testing => {:nested => {:access => true} } } }
    subject { DummyClass.new(response) }
    it "should return the id" do
      subject.id.should eq 1
    end
    it "should return the name" do
      subject.name.should eq "test"
    end

    it "should return access" do
      subject.testing.nested.access.should be_true
    end
  end
end

describe MiniResource::Request do
  let(:url) { 'http://mini.com/resource/' }
  let(:id)  { 1 }
  let(:uri) { 'http://mini.com/resource/1.json' }
  let(:parsed_response) { {"resource" => {"id" => "1"} } }

  context "#new" do
    subject { MiniResource::Request.new(url, id) }

    context "bad response" do
      let(:response) { File.open('spec/support/bad.json') }
      before do
        stub_request(:get, uri).to_return(response)
      end
      it "raises an error" do
        expect { subject }.to raise_error MiniResource::Request::ApiError
      end
    end

    context "missing response" do
      let(:response) { File.open('spec/support/missing.json') }
      before do
        stub_request(:get, uri).to_return(response)
      end
      it "raises an error" do
        expect { subject }.to raise_error MiniResource::Request::ResourceNotFound
      end
    end

    context "good response" do
      let(:response) { File.open('spec/support/good.json') }
      before do
        stub_request(:get, uri).to_return(response)
      end
      it "stores the uri" do
        subject.uri.to_s.should eq uri
      end
      it "stores the response" do
        subject.response.should_not be_nil
      end
    end
  end
end

describe MiniResource::Response do
  let(:parsed_response) { {:id => 1, :name => 'test', :deep => {:level => true } } }
  let(:response) { parsed_response.to_json }

  context "#new" do
    subject { MiniResource::Response.new(response) }

    it "parses the response" do
      subject.parsed_response.should eq parsed_response
    end
  end
end



