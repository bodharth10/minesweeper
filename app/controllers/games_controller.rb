class GamesController < ApplicationController

  $rows = 9
  $columns = 9
  $mine_count = 10
  $mine_cordinates = []
  $closed_boxes = $rows * $columns
  $status = "start"
  $time_spent = 0
  $click = 0
  $started_at = Time.now.to_i
  $is_clicked = true

  def index
    if params[:row_id] && params[:column_id]
      click_tile
    else
      reset_board_values
      reset_session
      arrange_board
      plant_mines
    end
  end

  private

  def reset_board_values
    $rows = 9
    $columns = 9
    $mine_count = 10
    $mine_cordinates = []
    $closed_boxes = $rows * $columns
    $status = "start"
    $time_spent = 0
    $click = 0
    $started_at = Time.now.to_i
    $is_clicked = true
  end

  def arrange_board
    board_data = Array.new($rows){Array.new($columns)}
    k = 1
    for i in 0..$rows - 1 do
      for j in 0..$columns - 1 do
        tile = {
          id: k,
          revealed: false,
          holder: "",
          value: 0,
        }
        board_data[i][j] = tile
        k = k + 1
      end
    end
    session[:board_data] = board_data
  end

  def plant_mines
    @board_data = session[:board_data]
    plant_mine(1)
    $mine_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @board_data[i][j][:holder] = "flag"
      set_count(i,j)
    end
    session[:board_data] = @board_data;
  end

  def plant_mine(i)
    if i > $mine_count
      return
    end
    single_mine = [*0..$rows - 1].sample(2)
    if $mine_cordinates.include?(single_mine)
      plant_mine(i)
    else
      $mine_cordinates.push(single_mine)
      plant_mine(i + 1)
    end

  end

  def set_count(i, j)
    
    a = i - 1
    if a >= 0
      set_increment_value(a, j)

      b = j - 1
      if b >= 0
        set_increment_value(a, b)
      end

      c = j + 1
      if c < $columns
        set_increment_value(a, c)
      end
    end

    d = j - 1
    if d >= 0
      set_increment_value(i, d)
    end

    e = j + 1
    if e < $columns
      set_increment_value(i, e)
    end

    f = i + 1
    if f < $rows
      set_increment_value(f, j)

      b = j - 1
      if b >= 0
        set_increment_value(f, b)
      end

      c = j + 1
      if c < $columns
        set_increment_value(f, c)
      end
    end
    
  end

  def set_increment_value(x, y)
    if @board_data[x][y][:holder] != 'flag'
      @board_data[x][y][:holder] = "number"
      @board_data[x][y][:value] = @board_data[x][y][:value] + 1
    end
  end

  def update_board_data(row_id, column_id)
    @board_data = session[:board_data]
    @board_data[row_id][column_id][:revealed] = true
    $closed_boxes = $closed_boxes - 1


    if @board_data[row_id][column_id][:holder] == "flag"
      
      # count no of closed boxes 
      if $closed_boxes > $mine_count - 1
        @board_data[row_id][column_id][:holder] = "bombed"

        # removing clicked flag box from mine cordinates
        bomb_cordinates = $mine_cordinates - [[row_id, column_id]]
        replace_flag_with_bomb(bomb_cordinates)

        $status = "lost"
      else
        show_mines
        $status = "won"
      end

    elsif @board_data[row_id][column_id][:holder] == ""
      
      # open closed boxes
      open_blank_closed_tiles(row_id, column_id)
      

    else
      
      if $closed_boxes == $mine_count
        show_mines
        $status = "won"
      end

    end

    session[:board_data] = @board_data
  end

  def open_blank_closed_tiles(i, j)
  
    adjascent_boxes = get_adjascent_boxes(i, j)

    adjascent_boxes.each do |ab|
      x = ab[0]
      y = ab[1]
      if !@board_data[x][y][:revealed] && (@board_data[x][y][:holder] == '' || @board_data[x][y][:holder] == 'number')
        @board_data[x][y][:revealed] = true
        $closed_boxes = $closed_boxes - 1

        if @board_data[x][y][:holder] == ''
          # take adjascent
          open_blank_closed_tiles(x, y)
        end
      end
    end

    return

  end

  def get_adjascent_boxes(i, j)

    closed_boxes = []
    
    a = i - 1
    if a >= 0
      closed_boxes.push([a, j])

      b = j - 1
      if b >= 0
        closed_boxes.push([a, b])
      end

      c = j + 1
      if c < $columns
        closed_boxes.push([a, c])
      end
    end

    d = j - 1
    if d >= 0
      closed_boxes.push([i, d])
    end

    e = j + 1
    if e < $columns
      closed_boxes.push([i, e])
    end

    f = i + 1
    if f < $rows
      closed_boxes.push([f, j])

      b = j - 1
      if b >= 0
        closed_boxes.push([f, b])
      end

      c = j + 1
      if c < $columns
        closed_boxes.push([f, c])
      end
    end

    return closed_boxes

  end

  def replace_flag_with_bomb(bomb_cordinates)
    bomb_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @board_data[i][j][:revealed] = true
      @board_data[i][j][:holder] = "bomb"
    end
  end

  def show_mines
    $mine_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @board_data[i][j][:revealed] = true
    end
  end

  def click_tile
    if $status == 'start'
      row_id = params[:row_id].to_i
      column_id = params[:column_id].to_i
      if row_id.between?(0, $rows - 1) && column_id.between?(0, $columns - 1)
        if $is_clicked
          $started_at = Time.now.to_i
          $is_clicked = false
        end
        $click = $click + 1

        $time_spent = Time.now.to_i - $started_at

        update_board_data(row_id, column_id)
      else
        # show error msg
      end
    end

    @board_data = session[:board_data]

    if $status == 'won'
      @best_score = $click * $time_spent / 100
      @score = Score.new
    end
  end
end
