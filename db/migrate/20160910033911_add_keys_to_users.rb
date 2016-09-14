class AddKeysToUsers < ActiveRecord::Migration[5.0]
  def change
    User.all.each {|u| u.update_attribute(:api_key, u.generate_api_key)}
  end
end
