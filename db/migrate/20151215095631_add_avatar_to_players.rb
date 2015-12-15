class AddAvatarToPlayers < ActiveRecord::Migration
  def self.up
    add_attachment :players, :avatar
  end

  def self.down
    remove_attachment :players, :avatar
  end
end
