require 'json'
require 'httparty'

class LLMTestGenerator
  LLM_API_URL = 'https://api.groq.com/openai/v1/chat/completions'
  API_KEY = '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'

  def initialize
    file_path = "input_data/create_thread_message_with_subject_spec.rb"
    @file_content = File.read(file_path)
  end

  def generate_test_cases(api_details)
    return 'No valid API details to generate test cases.' if api_details.nil? || api_details.empty?

    user_prompt = "Generate REST API test cases using RSpec (Ruby, HTTParty) for the following API specification:
                \n When creating a test for a post or a put request, ensure to have it as a method and return it as a JSON. Use JSON.generate to convert the hash to JSON
                \n When generating multiple expectations for validations, ensure to include it inside aggregate_failures block with a proper message for aggregate failure validations on what is it trying to do
                \n add proper failure messages in case of expectation failure
                \n do not include rspec/its
                \n add validation for status code, response body param validation, do not include to_be_successful and all.
                \n Do not include describe block for each API, include only for file level
                \n#{api_details}"
    
    messages = [
      {
        'role' => 'system',
        'content' => "You are a helpful assistant that generates RSPEC code for API tests. \n" \
                    "Your response must contain only Ruby RSPEC code enclosed in a single code block using triple backticks (```ruby ... ```). \n" \
                    "- Use proper rspec format.\n" \
                    "- Be a complete and executable rspec file. \n" \
                    "- Use 'describe' method of RSpec only for file level & not for 'it' level \n" \
                    "- Use 'before all' method of RSpec with hardcoded baseURI. \n" \
                    "- Do not includeRSpec.configure in the generated output. \n" \
                    "- Use only standard and correct imports (e.g., 'rest-client', 'rspec', 'httparty'). \n" \
                    "- Include extensive test with both positive and negative scenario. \n" \
                    "- Do not Write comments on the code. \n" \
                    "- Assert status code, response and response schema. \n" \
                    "- Do not include the class or module structure. Keep the focus only on the test block. \n" \
                    "- [IMPORTANT] Refer following rspec file as an example output & generate the extensive testcase output accordingly. \n" \
                    "- Sample output File Content: #{@file_content}"
      },
      {
        'role' => 'user',
        'content' => user_prompt
      }
    ]

    payload = {
      'model' => 'deepseek-r1-distill-llama-70b',
      'messages' => messages,
      'temperature' => 0.2
    }

    request_body = JSON.generate(payload)
    call_llm_api(request_body)
  rescue StandardError => e
    "Error building JSON payload: #{e.message}"
  end

  private

  def call_llm_api(request_body)
    response = HTTParty.post(LLM_API_URL,
                             body: request_body,
                             headers: {
                               'Content-Type' => 'application/json',
                               'Authorization' => "Bearer #{API_KEY}"
                             })
    response.body
  rescue StandardError => e
    "Error calling LLM API: #{e.message}"
  end
end