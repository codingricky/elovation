class AddSlackIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :slack_id, :string
    add_column :quotes, :user_id, :integer

    user_id = Player.with_name('Tony').try(:user).try(:id)
    Quote.update_all(user_id: user_id) if user_id

    name_to_slack_id = {'Elliott' => 'U02B95WEF',
                        'Andrew' => 'U04L672PF',
                        'Vinny' => 'U23EV6DN3',
                        'Ricky' => 'U0SF510BZ',
                        'Tony' => 'U1ULH4DQS'}

    name_to_slack_id.each do |name, slack_id|
      player = Player.with_name(name)
      if player
        user = User.find_by_email(player.email)
        user.update_attribute(:slack_id, slack_id) if user
      end
    end
  end
end
