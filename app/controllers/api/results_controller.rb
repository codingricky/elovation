class Api::ResultsController < ActionController::API

  def create
    winner_name = params[:winner]
    loser_name = params[:loser]

    winner = Player.with_name(winner_name)
    render json: {message: "winner can not be found"}, status: :bad_request unless winner; return if performed?
    winner_id = winner.id

    loser = Player.with_name(loser_name)
    render json: {message: "loser can not be found"}, status: :bad_request unless loser; return if performed?
    loser_id = loser.id

    game = Game.first

    result = {
        teams: {
            "0" => { players: winner_id },
            "1" => { players: loser_id }
        }
    }

    times = params[:times].to_i
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times

    1.upto(times) do
      ResultService.create(game, result)
    end
    render json: "created"
  end

  def create_from_txt
    render json: "invalid token", status: :unauthorized unless ENV["SLACK_TOKEN"] == params[:token]; return if performed?

    split_text = params[:text].split
    winner = Player.with_name(split_text[0])
    render json: {text: "winner can not be found"} unless winner; return if performed?
    winner_id = winner.id

    loser = Player.with_name(split_text[2])
    render json: {text: "loser can not be found"} unless loser; return if performed?
    loser_id = loser.id

    times = split_text.count >= 3 ? split_text[3].to_i : 1
    times = times <= 0 ? 1 : times
    times = times > 5 ? 5 : times

    game = Game.first
    result = {
        teams: {
            "0" => { players: winner_id },
            "1" => { players: loser_id }
        }
    }

    1.upto(times) do
      ResultService.create(game, result)
    end
    render json: {text: "created result"}
  end

end
