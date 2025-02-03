require 'httparty'
require 'rspec/autorun'
require 'rspec/expectations'

RSpec.describe 'Pet API Tests' do
  before(:all) do
    @base_uri = 'https://petstore.swagger.io/v2'
  end

  require 'httparty'
require 'rspec'

describe 'Pet API Tests' do
  before do
    @base_uri = 'https://petstore.swagger.io/v2'
  end

  it 'Add a new pet to the store' do
    pet = {
      id: 1,
      category: { id: 1, name: 'dogs' },
      name: 'doggie',
      status: 'available',
      tags: [{ name: 'tag' }]
    }
    
    response = HTTParty.post("#{@base_uri}/pet", body: pet.to_json, headers: { 'Content-Type' => 'application/json' })
    expect(response.code).to eq(200)
    expect(response.body).to include('doggie')
    expect(response.body).to include('available')
  end

  it 'Update an existing pet' do
    pet = {
      id: 1,
      category: { id: 1, name: 'dogs' },
      name: 'doggieUpdated',
      status: 'available',
      tags: [{ name: 'tag' }]
    }
    
    response = HTTParty.put("#{@base_uri}/pet", body: pet.to_json, headers: { 'Content-Type' => 'application/json' })
    expect(response.code).to eq(200)
    expect(response.body).to include('doggieUpdated')
  end

  it 'Find pets by status' do
    response = HTTParty.get("#{@base_uri}/pet/findByStatus", query: { status: 'available' })
    expect(response.code).to eq(200)
    expect(response.body).to include('available')
    expect(response.body).to match(/\[\{/)
  end

end