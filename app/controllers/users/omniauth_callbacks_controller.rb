class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    hd = request.env["omniauth.auth"]["extra"]["id_info"]["hd"]
    is_dius = "dius.com.au".eql?(hd)
    unless is_dius
      flash[:notice] = "Email address must have a domain of dius.com.au"
      redirect_to new_user_session_path and return
    end

    raw_info = request.env["omniauth.auth"]["extra"]["raw_info"]
    email = raw_info["email"]
    name = request.env["omniauth.auth"]["info"]["name"]
    player = Player.find_or_create_by(name: name, email: email)
    unless Rating.find_by_player_id(player.id)
      player.create_default_rating
    end

    @user = User.find_or_create_by(email: email) do |user|
      user.password = Devise.friendly_token[0,20]
    end
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    end

  end
end
