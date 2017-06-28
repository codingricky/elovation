require 'csv'

class ResultsExportController < ApplicationController

  before_action :authenticate_user!

  def export
    respond_to do |format|
      format.html
      format.csv { send_data Result.to_csv, filename:'results.csv'}
    end
  end

end
