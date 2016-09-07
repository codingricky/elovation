class Api::SlackController < ActionController::API

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
    slack_message = SlackMessage.new(winner_id, loser_id, game, times)
    1.upto(times) do
      ResultService.create(game, result)
    end
    slack_message.save_after_rating
    SlackService.notify(slack_message, nil)

    render json: {text: "created result"}
  end

end
