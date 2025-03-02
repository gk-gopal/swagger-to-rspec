require 'yaml'
require 'fileutils'
require 'pry'
require_relative '../lib/test_case_generator_utils/llm_test_generator'
require_relative '../lib/test_case_generator_utils/swagger_parser'
require_relative '../lib/test_case_generator_utils/test_code_generator'

class TestAutomationPipeline
  def self.run
    swagger_path = 'input_data/collab-threads-openapi3.yml'
    # 1. Parse the Swagger/OpenAPI spec
    parser = SwaggerParser.new
    api_details = parser.parse_swagger(swagger_path)

    api_details.each do |api_detail|
      begin
        # 2. Generate test case outline using LLM
        llm_gen = LLMTestGenerator.new
        llm_raw_output = llm_gen.generate_test_cases(api_detail)

        # 3. Extract only the Ruby code from the LLM response
        code_gen = TestCodeGenerator.new
        final_test_code = code_gen.extract_ruby_code(llm_raw_output)

        # 4. Extract the class name from the generated Ruby code

        file_name = File.basename(swagger_path, File.extname(swagger_path))
        formatted_path = api_detail[:path].gsub("/", "_") # Replace '/' with '_'
        output_file_name = "#{file_name}#{formatted_path}_#{api_detail[:method]}_spec.rb"

        # 5. Write generated code to a Ruby file with a name matching the class name
        File.write("spec/tests/#{output_file_name}", final_test_code)
        binding.pry
      rescue StandardError => e
        puts "Error generating test code: #{e.message}"
      end
    end
  end

end

TestAutomationPipeline.run
