require "dealer_hand"
require "player_hand"
require "shoe"

class Game
  property shoe : Shoe
  property dealer_hand : DealerHand
  property player_hands : Array(PlayerHand)
  property current_player_hand : Int32

  def initialize
    @shoe = Shoe.new
    @dealer_hand = DealerHand.new
    @player_hands = [] of PlayerHand
    @current_player_hand = 0
    deal_new_hand
  end

  def deal_new_hand
    shoe.shuffle if shoe.needs_to_shuffle?

    dealer_hand = DealerHand.new
    player_hand = PlayerHand.new
    player_hands.clear
    player_hands << player_hand
    current_player_hand = 0

    2.times do
      shoe.deal_card(player_hand)
      shoe.deal_card(dealer_hand)
    end

    if dealer_hand.up_card_is_ace? && !player_hand.is_blackjack?
      draw_hands
      ask_insurance
      return
    end

    if player_hand.is_done?
      dealer_hand.hide_down_card = false
      pay_hands
      draw_hands
      bet_options
      return
    end

    draw_hands
    player_hand.get_action
    save_game
  end

  def draw_hands

  end

  def ask_insurance

  end

  def pay_hands

  end

  def bet_options

  end

  def save_game

  end
end
