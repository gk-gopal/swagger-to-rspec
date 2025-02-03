require 'json'
require 'httparty'

class LLMTestGenerator
  LLM_API_URL = 'https://api.groq.com/openai/v1/chat/completions'
  API_KEY = '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'

  def generate_test_cases(api_details)
    return 'No valid API details to generate test cases.' if api_details.nil? || api_details.empty?

    user_prompt = "Generate REST API test cases using RSpec (Ruby, HTTParty) for the following API specification:\n#{api_details}"
    
    messages = [
      {
        'role' => 'system',
        'content' => "You are a helpful assistant that generates RSPEC code for API tests. \n" \
                    "Your response must contain only Ruby RSPEC code enclosed in a single code block using triple backticks (```ruby ... ```). \n" \
                    "- Use proper rspec format.\n" \
                    "- Do not include any additional text explanations. \n" \
                    "- Be a complete and executable rspec file. \n" \
                    "- Use only standard and correct imports (e.g., 'rest-client', 'rspec', 'httparty'). \n" \
                    "- Also do not include any additional tests other than the positive test. \n" \
                    "- Do not Write comments on the code. \n" \
                    "- Print output of the API response. \n" \
                    "- Use 'before' method of RSpec with hardcoded baseURI. \n" \
                    "- Do not include the class or module structure. Keep the focus only on the test block."
      },
      {
        'role' => 'user',
        'content' => user_prompt
      }
    ]

    payload = {
      'model' => 'deepseek-r1-distill-llama-70b',
      'messages' => messages,
      'temperature' => 0.2,
      'max_tokens' => 1500
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
