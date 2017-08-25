module Judgement
  class Rating < ActiveRecord::Base
    establish_connection JUDGEMENT_DB

    self.table_name = "ratings"

    belongs_to :player
  end
end