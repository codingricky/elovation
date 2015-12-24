class ResultsController < ApplicationController
  before_action :set_game
  before_action :authenticate_user!


  def create

    multiplier = params[:multiplier] || 1

    response = nil
    1.upto(multiplier.to_i) do
      response = ResultService.create(@game, params[:result])
    end

    if response.success?
      redirect_to dashboard_path
    else
      @result = response.result
      render :new
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])

    response = ResultService.destroy(result)

    redirect_to :back
  end

  def new
    @result = Result.new
    (@game.max_number_of_teams || 20).times{|i| @result.teams.build rank: i}
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end
end
