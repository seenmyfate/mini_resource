require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MiniResource do
  it 'contains no code smells' do
    Dir['lib/*.rb'].should_not reek
  end
end
