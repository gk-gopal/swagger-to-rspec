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
    # Ensure proper RSpec structure
    unless extracted_code.include?('RSpec.describe')
      extracted_code = <<~RUBY
          #{extracted_code}
        end
      RUBY
    end

    add_missing_imports(extracted_code)
  end

  private

  def add_missing_imports(ruby_code)
    # Ensure necessary `require` statements are at the top
    required_imports = <<~RUBY
      require 'httparty'
      require 'rspec/autorun'
      require 'rspec/expectations'
    RUBY

    # Prepend required imports if missing
    unless ruby_code.include?("require 'httparty'")
      ruby_code = required_imports + "\n\n" + ruby_code
    end

    ruby_code.strip
  end
end
