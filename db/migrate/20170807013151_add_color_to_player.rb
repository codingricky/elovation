class AddColorToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :color, :string

    Player.all.each {|p| p.update_attribute(:color, 'green')}
  end
end
