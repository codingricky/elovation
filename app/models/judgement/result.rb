module Judgement
  class Result < ActiveRecord::Base
    establish_connection JUDGEMENT_DB

    self.table_name = "results"
  end
end