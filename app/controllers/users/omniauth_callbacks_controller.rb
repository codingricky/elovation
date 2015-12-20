class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    hd = request.env["omniauth.auth"]["extra"]["id_info"]["hd"]
    is_dius = "dius.com.au".eql?(hd)
    return unless is_dius

    raw_info = request.env["omniauth.auth"]["extra"]["raw_info"]
    email = raw_info["email"]
    @user = User.find_by_email(email)
    unless @user
      @user = User.create(email: email,
           password: Devise.friendly_token[0,20])
    end


    if @user
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
    else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_session_url
    end

  end
end