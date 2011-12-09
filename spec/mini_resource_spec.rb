require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


class DummyClass
  extend MiniResource
end

describe MiniResource do
  let(:uri) { 'http://test.com' }
  let(:id)  { 1 }

  before do
    DummyClass.uri = uri
  end

  context "#uri" do
    it "stores a uri" do
      DummyClass.uri.should eq uri
    end
  end

  context "#find" do
    let(:response) { stub(:response => stub) }
    before do
      MiniResource::Request.should_receive(:new).with(uri,id).
        and_return(response)
    end
    it "finds" do
      DummyClass.find(id)
    end
  end
end

describe MiniResource::Request do
  let(:url) { 'http://mini.com/resource/' }
  let(:id)  { 1 }
  let(:uri) { 'http://mini.com/resource/1' }
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
