require 'yaml'
require 'fileutils'
require 'pry'
require_relative '../lib/test_case_generator_utils/llm_test_generator'
require_relative '../lib/test_case_generator_utils/swagger_parser'
require_relative '../lib/test_case_generator_utils/test_code_generator'

class TestAutomationPipeline
  def self.run
    swagger_path = 'input_data/countries.yml'

    # 1. Parse the Swagger/OpenAPI spec
    parser = SwaggerParser.new
    api_details = parser.parse_swagger(swagger_path)

    # 2. Generate test case outline using LLM
    llm_gen = LLMTestGenerator.new
    llm_raw_output = llm_gen.generate_test_cases(api_details)

    # 3. Extract only the Ruby code from the LLM response
    code_gen = TestCodeGenerator.new
    final_test_code = code_gen.extract_ruby_code(llm_raw_output)

    # 4. Extract the class name from the generated Ruby code
    class_name = extract_class_name(final_test_code)
    file_name = File.basename(swagger_path, File.extname(swagger_path))
    output_file_name = class_name && !class_name.empty? ? "#{class_name}_spec.rb" : "#{file_name}_auto_generated_spec.rb"

    # 5. Write generated code to a Ruby file with a name matching the class name
    File.write("spec/tests/#{output_file_name}", final_test_code)

    puts "Generated test code written to #{output_file_name}"
  end

  private

  # Extracts the Ruby class name from the given code.
  # It searches for a pattern matching "class <ClassName>".
  def self.extract_class_name(ruby_code)
    match = ruby_code.match(/class\s+(\w+)/)
    match ? match[1] : nil
  end
end

TestAutomationPipeline.run
