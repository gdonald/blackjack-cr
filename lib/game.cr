require "dealer_hand"
require "player_hand"
require "shoe"

class Game
  MIN_BET = 500
  MAX_BET = 10000000

  property num_decks : Int32 = 8
  property current_player_hand : Int32 = 0
  property current_bet : Int32 = 500
  property money : Int32 = 10000

  property shoe : Shoe
  property dealer_hand : DealerHand
  property player_hands : Array(PlayerHand)

  def initialize
    load_game

    @shoe = Shoe.new(num_decks)
    @dealer_hand = DealerHand.new
    @player_hands = [] of PlayerHand

    deal_new_hand
  end

  def load_game
    # TODO
  end

  def deal_new_hand
    @shoe.shuffle if @shoe.needs_to_shuffle?

    @dealer_hand = DealerHand.new
    player_hand = PlayerHand.new(self, @current_bet)

    2.times do
      @shoe.deal_card(player_hand)
      @shoe.deal_card(@dealer_hand)
    end

    @player_hands.clear
    @player_hands << player_hand
    @current_player_hand = 0

    if @dealer_hand.up_card_is_ace? && !player_hand.is_blackjack?
      draw_hands
      ask_insurance
      return
    end

    if player_hand.is_done?
      @dealer_hand.hide_down_card = false
      pay_hands
      draw_hands
      bet_options
      return
    end

    draw_hands
    player_hand.get_action
    save_game
  end

  def clear
    system("export TERM=linux; clear")
  end

  def draw_hands
    clear

    puts "Dealer: "
    puts @dealer_hand.draw

    puts "\nPlayer: #{Game.format_money(@money)}:\n"

    @player_hands.each_with_index do |player_hand, index|
      puts player_hand.draw(index)
    end
  end

  def all_bets
    bets = 0
    player_hands.each do |player_hand|
      bets += player_hand.bet
    end
    bets
  end

  def more_hands_to_play
    current_player_hand < player_hands.size - 1
  end

  def play_more_hands
    tmp = current_player_hand + 1
    current_player_hand = tmp

    player_hand = player_hands[current_player_hand]
    shoe.deal_card(player_hand)
    if player_hand.is_done?
      player_hand.process
      return
    end

    draw_hands
    player_hand.get_action
  end

  def play_dealer_hand
    if dealer_hand.is_blackjack?
      dealer_hand.hide_down_card = false
    end

    if !need_to_play_dealer_hand
      
    end
  end

  def ask_insurance

  end

  def pay_hands

  end

  def bet_options

  end

  def save_game

  end

  def self.format_money(money)
    "$#{sprintf("%.2f", money / 100.0)}"
  end
end
