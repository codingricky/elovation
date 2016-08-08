module ResultsHelper
  def player_options(index, current_player)
    current = [[current_player.name, current_player.id]]
    all = Player.order("name ASC").all.map { |p| [p.name, p.id] }
    if index == 0
      current
    else
      all - current
    end
  end

  def relation_options
    ['defeated', 'lost to']
  end

  def player_dropdown_tag_opts(index, current_player)
    if index == 0
      {selected: current_player.id}
    else
      {include_blank: ''}
    end
  end

  def player_dropdown_html_opts(index, current_player)
    opts = {
      class: "players",
    }
    if index == 0
      opts[:disabled] = true
      opts[:selected] = current_player.id
    else
      opts["data-placeholder"] = "Select Opponent: "
    end
    opts
  end
end
