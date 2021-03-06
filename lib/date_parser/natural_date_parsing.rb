require_relative "utils"

module DateParser
  
  # Handles the mechanics of natural language processing.
  #
  # == Methods
  #
  # <b>interpret_date(txt, creation_date, parse_single_years)</b>: 
  # Return an array of dates from the set of parameters.
  #
  # We parse in order of decreasing
  # strictness. I.e., a very specific phrase like "January 1st, 2013" will be parsed
  # before "January 1st," which will be parsed before just "2013". Whenever we
  # determine a phrase is part of a date, we remove the phrase after parsing.
  # So in the example "January 1st, 2013" we'll return only one date.
  #
  # If no dates are found, returns an empty array.
  #
  # <b>parse_one_word(word, creation_date, parse_single_years)</b>: Given a single word,
  # a string, tries to return a Date object.
  #
  # <b>parse_two_words(words, creation_date = nil)</b>: Attempts to return a Date object
  # given a string containing two words.
  #
  # <b>parse_three_words(words, creation_date = nil)</b>: Given three words,
  # attempts to return a Date object.
  #
  
  module NaturalDateParsing
    
    ###############################################
    ##
    ## Constants
    ##
    
    # Names of days as well as common shortened versions.
    SINGLE_DAYS = [
                   'mon', 'tue', 'wed', 'thur', 'fri', 'sat', 'sun',
                   'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 
                   'saturday', 'sunday', 'tues'
                  ]
                  
    # Phrases that denote a date relative to today (here often
    # called the creation_date)
    RELATIVE_DAYS = ['today', 'tomorrow', 'tonight', 'yesterday']
    
    # Names of months as well as common shortened versions
    MONTH = [
             'jan', 'feb', 'mar', 'may', 'june', 'july', 'aug', 'sept', 'oct',
             'nov', 'dec',
             'january', 'february', 'march', 'april', 'august', 'september',
             'october', 'november', 'december'
            ]
            
    # A list of numbers from [1, 31]
    NUMERIC_DAY = ('1'..'31').to_a
                  
    # Numbers from [1, 31] as well as the common suffixes (such as 1st, 2nd, e.t.c.)
    SUFFIXED_NUMERIC_DAY = [
                             '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', 
                             '8th', '9th', '10th', '11th', '12th', '13th', '14th', 
                             '15th', '16th', '17th', '18th', '19th', '20th', 
                             '21st', '22nd', '23rd','24th', '25th', 
                             '26th', '27th', '28th', '29th', '30th', '31st'
                           ]
    
    ###############################################
    ##
    ## Main Parsing/Processing Function
    ##
    
    # Processes a given text and returns an array of probable dates contained within.
    #
    # ==== Description
    # 
    # Tries to interpret dates from the given text, in order from strictest
    # interpretation to looser interpretations. No word can be part of two
    # different dates.
    #
    # Works by calling parse_three_words, parse_two_words, and parse_one_word
    # on the text. 
    #
    # ==== Attributes
    #
    # * +txt+ - The text to parse.
    #
    # * +creation_date+ - A Date object of when the text was created or released. 
    #   Defaults to nil, but if provided can make returned dates more accurate.
    #
    # * +parse_single_years+ - A boolean. If true, we interpret single numbers as
    #   years. This is a very broad assumption, and so defaults to false.
    #
    # * +parse_ambiguous_dates+ - Some phrases are not necessarily dates depending
    #   on context. For example "1st" may not refer to 
    #   the 1st of a month. This option toggles whether or not those
    #   phrases are considered dates. Defaults to true.
    #
    # ==== Examples
    #
    #    text = "Henry and Hanke created a calendar that causes each day to fall " +
    #           "on the same day of the week every year. They recommend its " +
    #           "implementation on January 1, 2018, a Monday."
    #    creation_date = Date.parse("July 6, 2016")
    #
    #    NaturalDateParsing.interpret_date(text, creation_date)
    #        #=> [#<Date: 2018-01-01 ((2458120j,0s,0n),+0s,2299161j)>, 
    #             #<Date: 2016-07-11 ((2457581j,0s,0n),+0s,2299161j)>]
    #
    #    NaturalDateParsing.interpret_date("No dates here!")
    #        #=> []
    #
    #    NaturalDateParsing.interpret_date("2012", nil, true)
    #        #=> [#<Date: 2012-01-01 ((2455928j,0s,0n),+0s,2299161j)>]
    #
    def NaturalDateParsing.interpret_date(
                                          txt, 
                                          creation_date = nil, 
                                          parse_single_years = false,
                                          parse_ambiguous_dates = true
                                          )
      possible_dates = []
      txt = Utils::clean_str(txt)
      words = txt.split(" ").map{|x| x.strip}
      
      # We use the while loop, as apparently there are cases where we try to subset
      # words despite the value of i being >= words.length - 3
      # TODO: Figure out why the above happens. Preferably return to for loop.
      # TODO: Cleaner way of structuring the below? I could break up the loops
      # into single functions. Consider.
      i = 0
      
      while (i <= words.length - 3) do
        subset_words = words[i..(i+2)]
        
        proposed_date = parse_three_words(subset_words, creation_date)
        
        if(! proposed_date.nil?)
          possible_dates << proposed_date
          words = Utils::delete_at_indices(words, i..(i+2))
          i -= 1
        end
        
        i += 1
      end
      
      i = 0
      
      while (i <= words.length - 2) do
        subset_words = words[i..(i+1)]
        proposed_date = parse_two_words(subset_words, creation_date)
        
        if(! proposed_date.nil?)
          possible_dates << proposed_date
          words = Utils::delete_at_indices(words, i..(i+1))
          i -= 1
        end
        
        i += 1
      end
      
      i = 0
      
      while (i <= words.length - 1) do
        subset_words = words[i]
        
        proposed_date = parse_one_word(subset_words, 
                                       creation_date, 
                                       parse_single_years,
                                       parse_ambiguous_dates)
        
        if(! proposed_date.nil?)
          possible_dates << proposed_date
          words.delete_at(i)
          i -= 1
        end
        
        i += 1
      end
      
      return possible_dates
    end
    
    
    ###############################################
    ##
    ## Parse Cases (1 word, 2 words, 3 words)
    ##
    
    # Takes a single word and tries to return a date.
    #
    # If no date can be interpreted from the word, returns nil. We consider these
    # cases:
    # * DAY (mon, tuesday, e.t.c.)
    # * A relative day (today, tomorrow, tonight, yesterday)
    # * Dates of the form MM/DD
    # * Numbers such as [1st, 31st]
    # * MONTH (jan, february, e.t.c.)
    # * YYYY (2012, 102. Must be enabled.)
    # * YYYY-MM-DD, DD-MM-YYYY, MM-DD-YYYY
    #
    # ==== Attributes
    #
    # * +word+ - A String, preferably consisting of a single word.
    #
    # * +creation_date+ - A Date object of when the text was created or released. 
    #   Defaults to nil, but if provided can make returned dates more accurate.
    #
    # * +parse_single_years+ - A boolean. If true, we interpret single numbers as
    #   years. This is a very broad assumption, and so defaults to false.
    #
    # * +parse_ambiguous_dates+ - Some phrases are not necessarily dates depending
    #   on context. For example "1st" may not refer to 
    #   the 1st of a month. This option toggles whether or not those
    #   phrases are considered dates. Defaults to true.
    #
    def NaturalDateParsing.parse_one_word(
                                          word, 
                                          creation_date = nil, 
                                          parse_single_years = false,
                                          parse_ambiguous_dates = true
                                          )
      
      if SINGLE_DAYS.include? word
        proposed_date = Date.parse(word)
        
        # If we have the creation_date date, we can try to be a little smarter
        if(! creation_date.nil?)
          weeks_to_shift = difference_in_weeks(Date.today, creation_date)
                                                           
          proposed_date = proposed_date - (weeks_to_shift * 7)
          
          # Right now though, it should be within 1 week of accuracy, and either one
          # week ahead or one week behind.
          # The solution is pretty simple. If the proposed date 
          # is more than a week ahead of the creation date, then go back one week.
          if proposed_date - creation_date > 7
            proposed_date = proposed_date - 7
          elsif proposed_date - creation_date < 0
            proposed_date = proposed_date + 7
          end
        end
        
        return proposed_date
      end
      
      # Parsing phrases like "yesterday", "today", "tonight"
      if RELATIVE_DAYS.include? word
        if word == 'today' || word == 'tonight'
          if creation_date.nil?
            return Date.today
          else
            return creation_date
          end
        elsif word == 'yesterday'
          if creation_date.nil?
            return Date.today - 1
          else
            return creation_date - 1
          end
        elsif word == "tomorrow"
          return creation_date + 1
        end
      end
      
      # Parsing strings like "23rd"
      if (SUFFIXED_NUMERIC_DAY.include? word) && parse_ambiguous_dates
        return numeric_single_day(word, creation_date)
      end
      
      # Parsing month names 
      if MONTH.include? word
        return default_month(word, creation_date)
      end
      
      # In this case, we assume it's a year!
      if parse_single_years && (Utils::is_int? word)
        return default_year(word)
      end
      
      # Parsing XX-XX-XXXX, XXXX-XX-XX, XX/XX/XXXX, or XXXX/XX/XX
      if full_numeric_date?(word)
        return full_numeric_date(word)
      end
      
      # Parsing strings of the form XX/XX
      if slash_date?(word)
        return slash_date(word, creation_date)
      end
    end
    
    
    # Takes two words and tries to return a date.
    #
    # If no date can be interpreted from the word, returns nil. In this case,
    # we look for dates of this form:
    # * MONTH DAY
    # * DAY MONTH
    #
    # ==== Attributes
    #
    # * +words+ - An array of two words, downcased and stripped.
    #
    # * +creation_date+ - A Date object of when the text was created or released. 
    #   Defaults to nil, but if provided can make returned dates more accurate.
    #
    def NaturalDateParsing.parse_two_words(words, creation_date = nil)
      
      if MONTH.include?(words[0]) && _weak_day?(words[1])
        return month_day(words, creation_date)
      end

      if MONTH.include?(words[1]) && _weak_day?(words[0])
        return month_day([words[1], words[0]], creation_date)
      end

    end
    
    
    # Takes three words and tries to return a date.
    #
    # If no date can be interpreted from the word, returns nil. In this case,
    # assumes the word can take these forms:
    # * MONTH DAY YEAR
    #
    # ==== Attributes
    #
    # * +words+ - An array of three words, downcased and stripped.
    #
    # * +creation_date+ - A Date object of when the text was created or released. 
    #   Defaults to nil, but if provided can make returned dates more accurate.
    #
    def NaturalDateParsing.parse_three_words(words, creation_date = nil)
  
      if MONTH.include?(words[0]) && _weak_day?(words[1]) && Utils::is_int?(words[2])
        return Date.parse(words.join(" "))
      end
      
    end
    
    ###############################################
    ##
    ## Parse Functions
    ##
    
    # Given a single word, assumes the word is of the form XX/XX and returns
    # the appropriate Date object. If not possible, returns nil.
    def NaturalDateParsing.slash_date(word, creation_date = nil)
      samp = word.split('/')
      month = samp[0].to_i
      day = samp[1].to_i
      
      if month > 0 && month <= 12 && day > 0 && day <= 31
        # TODO: IMPROVE EXCEPTION HANDLING.
        begin
          proposed_date = Date.parse(word)
          if(! creation_date.nil?) ## We're sensitive to only years here.
            years_diff = Date.today.year - creation_date.year
            proposed_date = proposed_date << (12 * years_diff)
          end
          return proposed_date
        rescue ArgumentError
          return nil
        end
      end
    end
    
    # Parses an array containing two elements (single words) on the assumption
    # that the array is of the form ["MONTH", "DAY"]
    def NaturalDateParsing.month_day(words, creation_date = nil)
      begin
        proposed_date = Date.parse(words.join(" "))
        
        diff_in_years = creation_date.nil? ? 0 : (creation_date.year - Date.today.year)
        
        return proposed_date >> diff_in_years * 12
      rescue ArgumentError
        return nil
      end
    end
    
    # Parses a single numeric date (1st, 2nd, 3rd, e.t.c.).
    def NaturalDateParsing.numeric_single_day(word, creation_date = nil)
      diff_in_months = creation_date.nil? ? 0 : (creation_date.year * 12 + creation_date.month) - 
                                                (Date.today.year * 12 + Date.today.month)
      
      begin
        return Date.parse(word) >> diff_in_months
      rescue ArgumentError
        ## If an ArgumentError arises, Date is not convinced it's a date.
        return nil
      end
    end
    
    # Parses a single word of the form XXXX-XX-XX, DD-MM-YYYY or MM-DD-YYYY
    # Also accepts words of the form XXXX/XX/XX
    def NaturalDateParsing.full_numeric_date(word)
      demarcating_token = get_demarcating_token(word)
      
      subparts = word.split(demarcating_token)
      
      # This is a weak check to see where the year is
      year_index = (subparts[0].to_i).abs > 31 ? 0 : 2
      
      # Then we assume it's of the form YYYY-MM-DD
      if year_index == 0
        return Date.parse(word)
      else
        # We check the subparts to try to see which part is DD.
        # If we can't determine it, we assume it's International Standard Format,
        # or DD-MM-YY
        
        if subparts[1].to_i > 12
          # American Standard (MM-DD-YYYY)
          subparts[0] = numeric_month_to_string(subparts[0].to_i)
          return Date.parse(subparts.join(" "))
          
        else
          # International Standard (DD-MM-YYYY)
          return Date.parse(word)
        end
      end
      
      return Date.parse(word)
    end
    
    
    private
    
    ##############################################
    ##
    ## Private Functions
    ##
    
    def NaturalDateParsing._weak_day?(word)
      return (NUMERIC_DAY.include? word) || (SUFFIXED_NUMERIC_DAY.include? word)
    end
    
    def NaturalDateParsing.default_year(year)
      return Date.parse("Jan 1 " + year)
    end
    
    ## TODO. NOT SENSITIVE TO YEAR.
    def NaturalDateParsing.default_month(month, released = nil)
      this_year = released.nil? ? Date.today.year : released.year
      return Date.parse(month + " " + this_year.to_s)
    end
    
    def NaturalDateParsing.suffix(number)
      int = number.to_i
      
      ## Check to see if the least significant digit is 1.
      if int & 1 == 1
        return int.to_s + "st"
      else
        return int.to_s + "th"
      end
    end
    
    ## Be careful with this.
    ## date1 is the later date.
    def NaturalDateParsing.difference_in_weeks(date1, date2)
      return ((date1 - date2) / 7).to_i
    end
    
    # Determines if a given date could be a slash date.
    # I.e., of the form XX/XX
    def NaturalDateParsing.slash_date?(word)
      substrings = word.split("/")
      
      if substrings.size != 2
        return false
      end
      
      for substring in substrings do
        if !Utils.is_int?(substring)
          return false
        end
      end
      
      return true
    end
    
    # Is it generally of the form XXXX-XX-XX or XXXX/XX/XX?
    def NaturalDateParsing.full_numeric_date?(word)
      demarcating_token = get_demarcating_token(word)
      substrings = word.split(demarcating_token)
      
      if substrings.length != 3
        return false
      end
      
      for substring in substrings do
        if !Utils.is_int?(substring)
          return false
        end
      end
      
      return true
    end
    
    # Converts a numeric month to a string.
    def NaturalDateParsing.numeric_month_to_string(numeric)
      months = ["january", "february", "march", "april", "may", "june",
                "july", "august", "september", "october", "november",
                "december"]
      
      return months[numeric - 1]
    end
    
    # Given a string, tries to determine if the word
    # contains a demarcating token such as '-' or '/'
    # If so, returns that demarcating token. Assumes that
    # only one such token is present.
    #
    # If no such token is found, returns an empty string.
    def NaturalDateParsing.get_demarcating_token(word)
      demarcating_token = ""
      
      if word.include? "-"
        demarcating_token = "-"
      elsif word.include? "/"
        demarcating_token = "/"
      end
      
      return demarcating_token
    end
    
  end
end
