module Judgement
  class Quote < ActiveRecord::Base
    establish_connection JUDGEMENT_DB

    self.table_name = "quotes"
  end
end