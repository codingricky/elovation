
class Api::QuoteController < Api::ApiBaseController

  before_action :authenticate, only: [:index]

  def index
    render json: {quote: SlackMessage.just_the_quote}
  end

end