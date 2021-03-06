Gem::Specification.new do |s|
  s.name        = 'date_parser'
  s.version     = '0.1.51'
  s.date        = '2017-02-07'
  s.summary     = "Robust natural language parsing for dates."
  s.description = "DateParser is a simple, fast, and effective way to " +
                  "parse dates from natural language text."
  s.authors     = ["Ryan Kwon"]
  s.email       = 'rynkwn@gmail.com'
  s.files       = ["lib/date_parser.rb", 
  
                   "lib/date_parser/natural_date_parsing.rb",
                   "lib/date_parser/utils.rb"]
  s.test_files  = ["lib/spec/date_parser_spec.rb",
                   "lib/spec/natural_date_parsing_spec.rb"]
  
  s.extra_rdoc_files = %w[README.md NEWS.md]
  s.homepage    = 'https://github.com/rynkwn/DateParser'
  s.license     = 'MIT'
end