require 'yaml'
require 'openapi3_parser'

class SwaggerParser
  def parse_swagger(swagger_file_path)
    begin
      # Load and parse OpenAPI spec directly from YAML
      document = Openapi3Parser.load_file(swagger_file_path)

      # Check for validation errors
      unless document.valid?
        puts "❌ OpenAPI spec errors: #{document.errors.join(', ')}"
        return nil
      end

      result = extract_api_details(document)
    rescue StandardError => e
      puts "❌ Error while parsing Swagger file: #{e.message}"
      nil
    end
  end

  private

  def extract_api_details(document)
    result = []
    http_methods = ['get', 'post', 'put', 'delete', 'patch', 'head', 'options']
  
    document.paths.each do |path, path_item|
  
      http_methods.each do |method|
        if path_item.respond_to?(method) # Check if the method exists in path_item
          details = path_item.send(method) # Get the details for this HTTP method
          if details # Check if the details are not nil
            summary = details&.[]('summary') # Safely extract the summary if it exists
  
            # Add the details to the result
            result << { path: path, method: method.upcase, summary: summary }
          end
        end
      end
    end
  
    result
  end  
end