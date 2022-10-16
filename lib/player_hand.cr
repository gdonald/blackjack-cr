require "hand"

class PlayerHand < Hand

  MAX_PLAYER_HANDS = 7

  property stood : Bool = false
  property played : Bool = false
  property payed : Bool = false
  property status : Hand::Status = Status::Unknown
  property game : Game
  property bet : Float64

  def initialize(@game, @bet)
  end

  def self.is_busted?(player_hand : PlayerHand)
    PlayerHand.get_value(player_hand, Count::Soft) > 21
  end

  def self.get_value(player_hand : PlayerHand, count_method : Hand::Count)
    total = 0

    player_hand.cards.each_with_index do |card, index|
      tmp_v = card.value + 1
      v = tmp_v > 9 ? 10 : tmp_v
      v = 11 if count_method == Count::Soft && v == 1 && total < 11
      total += v
    end

    count_method == Count::Soft && total > 21 ? PlayerHand.get_value(player_hand, Count::Hard) : total
  end

  def self.draw(game : Game, player_hand : PlayerHand, index : Int32)
    output = " "

    player_hand.cards.each_with_index do |card, index|
      output += Card.draw(game, card)
      output += " "
    end

    output += " ⇒  #{PlayerHand.get_value(player_hand, Count::Soft)} "

    if player_hand.status == Status::Lost
      output += " -"
    elsif player_hand.status == Status::Won
      output += " +"
    elsif player_hand.status == Status::Unknown
      output += " "
    end

    output += "#{Game.format_money(player_hand.bet)}"

    if !player_hand.played && index == game.current_player_hand
      output += " ⇐"
    end

    output += " "

    if player_hand.status == Status::Lost
      if PlayerHand.is_busted?(player_hand)
        output += "Busted!"
      else
        output += "Lose!"
      end
    elsif player_hand.status == Status::Won
      if player_hand.is_blackjack?
        output += "Blackjack!"
      else
        output += "Won!"
      end
    elsif player_hand.status == Status::Push
      output += "Push"
    end

    output += "\n\n"

    output
  end

  def is_done?
    if played || stood || is_blackjack? || PlayerHand.is_busted?(self) || 21 == PlayerHand.get_value(self, Count::Soft) || 21 == PlayerHand.get_value(self, Count::Hard)
      @played = true

      if !payed
        if PlayerHand.is_busted?(self)
          @payed = true
          @status = Status::Lost
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
    return false if stood || cards.size != 2 || PlayerHand.is_busted?(self) || is_blackjack?
    true
  end

  def can_stand?
    return false if stood || PlayerHand.is_busted?(self) || is_blackjack?
    true
  end

  def can_hit?
    return false if played || stood || 21 == PlayerHand.get_value(self, Count::Hard) || is_blackjack? || PlayerHand.is_busted?(self)
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
    @played = true
    @bet *= 2

    process if is_done?
  end

  def stand
    @stood = true
    @played = true

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

  def clone
    player_hand = PlayerHand.new(game, bet)
    cards.each do |card|
      player_hand.cards << card
    end
    player_hand
  end
end
