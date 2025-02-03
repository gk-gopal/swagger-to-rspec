require 'httparty'
require 'rspec/autorun'
require 'rspec/expectations'

RSpec.describe 'Pet API Tests' do
  before(:all) do
    @base_uri = 'https://petstore.swagger.io/v2'
  end

  require 'httparty'
require 'rspec/autorun'

describe 'Countries API' do
  before do
    @base_uri = 'http://localhost:4567'
  end

  describe 'GET /all' do
    it 'returns a list of all countries' do
      response = HTTParty.get("#{@base_uri}/all")
      expect(response.code).to eq(200)
      result = JSON.parse(response.body)
      expect(result).to be_an(Array)
      expect(result).to be_any
    end
  end

  puts response.body

end