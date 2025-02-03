require 'json'

class TestCodeGenerator
  def extract_ruby_code(llm_response)
    begin
      root_node = JSON.parse(llm_response)
      choices_node = root_node['choices']

      if choices_node.is_a?(Array) && choices_node.any?
        message_node = choices_node[0]['message']
        content = message_node['content'].strip

        if content.include?('```ruby')
          start = content.index('```ruby')
          finish = content.rindex('```')

          if start && finish && finish > start
            content = content[(start + '```ruby'.length)...finish].strip
          end
        end

        return format_rspec_code(content)
      end
    rescue StandardError => e
      puts "Error parsing response: #{e.message}"
    end

    format_rspec_code(llm_response)
  end

  def format_rspec_code(extracted_code)
    extracted_code = extracted_code.strip

    # Remove `module` and `class` definitions
    extracted_code.gsub!(/^module\s+\w+\s*$/, '')
    extracted_code.gsub!(/^class\s+\w+\s*$/, '')
    extracted_code.gsub!(/^end\s*$/, '') # Remove standalone `end` if necessary

    # Convert `def test_method_name` to `it 'should test something' do`
    extracted_code.gsub!(/^def\s+(\w+)/, 'it "\1" do')

    # Ensure a single `describe` block without unnecessary nesting
    unless extracted_code.include?('RSpec.describe')
      extracted_code = <<~RUBY
        require 'httparty'
        require 'rspec/autorun'
        require 'rspec/expectations'

        RSpec.describe 'Pet API Tests' do
          before(:all) do
            @base_uri = 'https://petstore.swagger.io/v2'
          end

          #{extracted_code}
        end
      RUBY
    end

    add_missing_imports(extracted_code)
  end

  private

  def add_missing_imports(ruby_code)
    # Ensure the necessary `require` statements are at the top
    required_imports = <<~RUBY
      require 'httparty'
      require 'rspec/autorun'
      require 'rspec/expectations'
    RUBY

    # Ensure `require` statements are at the top
    unless ruby_code.include?("require 'httparty'")
      ruby_code = required_imports + "\n\n" + ruby_code
    end

    ruby_code.strip
  end
end
