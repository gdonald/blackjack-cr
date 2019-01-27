require "hand"

class PlayerHand < Hand

  MAX_PLAYER_HANDS = 7

  property stood : Bool = false
  property played : Bool = false
  property payed : Bool = false
  property status : Hand::Status = Status::Unknown
  property game : Game
  property bet : Int32

  def initialize(@game, @bet)
  end

  def get_value(count_method : Hand::Count)
    total = 0

    cards.each_with_index do |card, index|
      tmp_v = card.value + 1
      v = tmp_v > 9 ? 10 : tmp_v
      v = 11 if count_method == Count::Soft && v == 1 && total < 11
      total += v
    end

    count_method == Count::Soft && total > 21 ? get_value(Count::Hard) : total
  end

  def draw(index : Int32)
    output = " "

    cards.each_with_index do |card, index|
      output += "#{card} "
    end

    output += " ⇒  #{get_value(Count::Soft)} "

    if status == Status::Lost
      output += "-"
    elsif status == Status::Won
      output += "+"
    end

    output += " #{Game.format_money(bet)}"
    
    if !played && index == game.current_player_hand
      output += " ⇐"
    end

    output += " "

    if status == Status::Lost
      if is_busted?
        output += "Busted!"
      else
        output += "Lose!"
      end
    elsif status == Status::Won
      if is_blackjack?
        output += "Blackjack!"
      else
        output += "Won!"
      end
    elsif status == Status::Push
      output += "Push"
    end

    output += "\n\n"

    output
  end

  def is_done?
    if played || stood || is_blackjack? || is_busted? || 21 == get_value(Count::Soft) || 21 == get_value(Count::Hard)
      played = true

      if !payed
        if is_busted?
          payed = true
          status = Status::Lost
          game.money -= bet
        end
      end

      return true
    end

    false
  end

  def can_split?
    return false if stood || game.player_hands.size >= PlayerHand::MAX_PLAYER_HANDS
    return false if game.money < game.all_bets + bet
    return true if cards.size == 2 && cards[0].value == cards[1].value
    false
  end

  def can_dbl?
    return false if game.money < game.all_bets + bet
    return false if stood || cards.size != 2 || is_busted? || is_blackjack?
    true
  end

  def can_stand?
    return false if stood || is_busted? || is_blackjack?
    true
  end

  def can_hit?
    return false if played || stood || 21 == get_value(Count::Hard) || is_blackjack? || is_busted?
    true
  end

  def hit
    game.shoe.deal_card(self)

    if is_done?
      process
      return
    end

    game.draw_hands
    game.player_hands[game.current_player_hand].get_action
  end

  def dbl
    game.shoe.deal_card(self)
    played = true

    tmp = bet * 2
    bet = tmp
    
    process if is_done?
  end

  def stand
    stood = true
    played = true

    if game.more_hands_to_play
      game.play_more_hands
      return
    end

    game.play_dealer_hand
    game.draw_hands
    game.bet_options
  end

  def process
    if game.more_hands_to_play
      game.play_more_hands
      return
    end

    game.play_dealer_hand
    game.draw_hands
    game.bet_options
  end

  def get_action
    output = " "

    output += "(H) Hit  " if can_hit?
    output += "(S) Stand  " if can_stand?
    output += "(P) Split  " if can_split?
    output += "(D) Double  " if can_dbl?
    output += "\n"

    puts output

    while true
      br = false
      
      case STDIN.raw &.read_char
      when 'h'
        br = true
        hit
      when 's'
        br = true
        stand
      when 'p'
        br = true
        game.split_current_hand
      when 'd'
        br = true
        dbl
      else
        br = true
        game.clear
        game.draw_hands
        get_action
      end

      break if br
    end
  end
end
