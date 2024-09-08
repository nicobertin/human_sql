# HumanSql

`HumanSql` is a gem that converts natural language queries into ActiveRecord queries using the OpenAI API. This gem allows developers to execute complex database queries by simply providing instructions in plain English (or another supported language).

## Installation

After releasing to RubyGems.org, you can install the gem and add it to your application's Gemfile by executing:

```bash
bundle add human_sql
```

If Bundler is not being used to manage dependencies, you can install the gem by executing:

```bash
gem install human_sql
```

### Post Installation
Once the gem is installed, you'll need to configure it by creating an initializer. In your Rails application, create a file named config/initializers/human_sql.rb and add the following:

```ruby
HumanSQLConfig = {
  api_key: 'your_openai_api_key',   # Replace with your actual OpenAI API key
  default_language: 'english'       # You can change this to 'spanish', 'japanese', etc.
}
```

Make sure to replace 'your_openai_api_key' with your actual API key from OpenAI. The default_language setting controls the language used for the natural language responses.

### Usage

To use HumanSql in your application, simply call the run method on HumanSQL::QueryBuilder with a natural language query. For example:

```ruby
result = HumanSQL::QueryBuilder.run("Give me the first user from my database")
puts result
```

This will convert the natural language query into an ActiveRecord query, execute it, and return the results formatted in the specified language.

### Disclaimer

IMPORTANT: By using this gem, you agree that the author is not responsible for any kind of data loss, damage, or issues that may arise from the use of this software. You are solely responsible for verifying the safety of the generated queries before running them in your production environment or on critical data. Use at your own risk.

### Development

After checking out the repo, run bin/setup to install dependencies. You can also run bin/console for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run:

```bash
bundle
```

To release a new version, update the version number in version.rb, and then run:

```bash
bundle exec rake release
```

This will create a git tag for the version, push git commits and the created tag, and push the .gem file to rubygems.org.

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nicobertin/human_sql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the code of conduct.

### License
The gem is available as open source under the terms of the MIT License.

### Code of Conduct
Everyone interacting in the HumanSql project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the code of conduct.