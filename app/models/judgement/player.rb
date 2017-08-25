module Judgement
  class Player < ActiveRecord::Base
    establish_connection JUDGEMENT_DB

    self.table_name = "players"

    has_one :rating
  end
end