module DateUtils
  # Parse words of the form XX/XX
  def DateUtils.parse_slash_date(word, released = nil)
    samp = word.split('/')
    month = samp[0].to_i
    day = samp[1].to_i
    
    if month > 0 && month <= 12 && day > 0 && day <= 31
      # TODO: IMPROVE EXCEPTION HANDLING.
      # bolted exception handling.
      begin
        proposed_date = Date.parse(word)
        if(! released.nil?) ## We're sensitive to only years here.
          years_diff = Date.today.year - released.year
          proposed_date = proposed_date << (12 * years_diff)
        end
        return proposed_date
      rescue ArgumentError
        return nil
      end
    end
  end
  
  # We parse a numeric date (1st, 2nd, 3rd, e.t.c.) given a release date
  def DateUtils.parse_numeric(word, released = nil)
    diff_in_months = released.nil? ? 0 : (released.year * 12 + released.month) - 
                                         (Date.today.year * 12 + Date.today.month)
    
    Date.parse(word) >> diff_in_months
  end
  
  # Effectively shifts start date for Date.parse() operations.
  #def DateUtils.shift_start_date(old_date, new_start_date)
    # Parsing a relative day (Sensitive to week, month, year)
    # Parsing a relative month (Sensitive to year)
    
  #end
end