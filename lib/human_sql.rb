require 'net/http'
require 'uri'
require 'json'

require_relative 'human_sql/version'

module HumanSQL
  class QueryBuilder
    OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'
    
    def initialize(user_input)
      @user_input = user_input
      @schema_content = File.read(Rails.root.join('db', 'schema.rb'))
    end

    def self.run(user_input)
      new(user_input).get_results
    end

    def generate_query
      prompt = build_query_prompt(@user_input, @schema_content)

      generated_query_response = call_openai_service(prompt)&.strip
      extracted_query = extract_active_record_query(generated_query_response)
      
      extracted_query
    end

    def get_results
      generated_query = generate_query
      raise "Could not generate a valid query." if generated_query.blank?

      results = execute_query(generated_query)
      raise "No results found." if results.blank?

      formatted_results = format_results_for_openai(results)
      natural_language_response = generate_natural_language_response(formatted_results, @user_input)

      natural_language_response
    rescue StandardError => e
      process_error_in_natural_language(e.message)
    end

    private

    def build_query_prompt(user_input, schema_content)
      prompt = <<-PROMPT
        The user has requested: "#{user_input}".
        This is the database schema:

        #{schema_content}

        Please generate an ActiveRecord query based on this schema. The query should be in a single line of code and return the result according to the user's request. 
        If it's necessary to access multiple related tables, prefer to use `includes` over `joins` to optimize data loading.
      PROMPT
      prompt
    end

    def call_openai_service(prompt)
      body = {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: "You are an assistant that converts natural language into ActiveRecord queries and explains results in natural language."
          },
          {
            role: "user",
            content: prompt
          }
        ]
      }

      uri = URI.parse(OPENAI_API_URL)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{HumanSQLConfig[:api_key]}"
      request.body = body.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      parse_response(response)
    end

    def parse_response(response)
      if response.is_a?(Net::HTTPSuccess)
        response_body = JSON.parse(response.body)
        response_body.dig('choices', 0, 'message', 'content')
      else
        error_message = "Error in OpenAI API: #{response.code} - #{response.body}"
        raise error_message
      end
    end

    def extract_active_record_query(response)
      return nil if response.blank?

      code_lines = response.lines.select { |line| line.strip.match(/^[A-Za-z]\w*\./) }
      return nil if code_lines.empty?
      code_lines.join("\n").strip
    end

    def execute_query(generated_query)
      eval(generated_query)
    rescue StandardError
      nil
    end

    def format_results_for_openai(results)
      if results.is_a?(ActiveRecord::Relation) || results.is_a?(Array)
        formatted = results.map do |result|
          if result.respond_to?(:attributes)
            result.attributes.map { |key, value| "#{key}: #{value}" }.join(', ')
          else
            result.to_s
          end
        end.join("\\n")
        formatted
      else
        formatted = results.respond_to?(:attributes) ? results.attributes.map { |key, value| "#{key}: #{value}" }.join(', ') : results.to_s
        formatted
      end
    end

    def generate_natural_language_response(formatted_results, user_input)
      prompt = <<-PROMPT
        The user requested: "#{user_input}".
        Here are the results obtained from the database:

        #{formatted_results}

        Please generate a natural language description that clearly and understandably explains these results to the user in #{HumanSQLConfig[:default_language]}.
        Do not ask for confirmation, just confirm what has already been done.
      PROMPT

      call_openai_service(prompt)
    end

    def process_error_in_natural_language(error_message)
      prompt = <<-PROMPT
        An error occurred while processing the user's query. The error is as follows:

        "#{error_message}"

        Please generate a natural language response that explains the error in a way that is understandable to the user in #{HumanSQLConfig[:default_language]}.
      PROMPT

      call_openai_service(prompt)
    end
  end
end
