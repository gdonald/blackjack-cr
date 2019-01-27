require "dealer_hand"
require "player_hand"
require "shoe"

class Game
  SAVE_FILE = "bj.txt"
  MIN_BET = 500.0
  MAX_BET = 10000000.0
  START_MONEY = 10000.0

  property num_decks : Int32 = 8
  property current_player_hand : Int32 = 0
  property current_bet : Float64 = 500
  property money : Float64 = START_MONEY

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
    @current_player_hand += 1

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
      dealer_hand.played = true
      pay_hands
      return
    end

    dealer_hand.hide_down_card = false

    soft_count = dealer_hand.get_value(Hand::Count::Soft)
    hard_count = dealer_hand.get_value(Hand::Count::Hard)
    while soft_count < 18 && hard_count < 17
      shoe.deal_card(dealer_hand)
      soft_count = dealer_hand.get_value(Hand::Count::Soft)
      hard_count = dealer_hand.get_value(Hand::Count::Hard)
    end

    dealer_hand.played = true
    pay_hands
  end

  def need_to_play_dealer_hand
    player_hands.each do |player_hand|
      return true if !(player_hand.is_blackjack? || player_hand.is_busted?)
    end
    false
  end

  def split_current_hand
    current_hand = player_hands[current_player_hand]

    if !current_hand.can_split?
      draw_hands
      current_hand.get_action
      return
    end

    player_hands << PlayerHand.new(self, current_bet)

    x = player_hands.size - 1
    while x > current_player_hand
      player_hand = player_hands[x - 1].clone
      player_hands[x] = player_hand
      x -= 1
    end

    this_hand = player_hands[current_player_hand]
    split_hand = player_hands[current_player_hand + 1]

    split_hand.cards.clear
    card = this_hand.cards.last
    split_hand.cards << card
    this_hand.cards.pop
    shoe.deal_card(this_hand)

    if this_hand.is_done?
      this_hand.process
      return
    end

    draw_hands
    player_hands[current_player_hand].get_action
  end

  def ask_insurance
    puts " Insurance?  (Y) Yes  (N) No"

    br = false
    while true
      case STDIN.raw &.read_char
      when 'y'
        br = true
        insure_hand
      when 'n'
        br = true
        no_insurance
      else
        br = true
        clear
        draw_hands
        ask_insurance
      end

      break if br
    end
  end

  def insure_hand
    player_hand = player_hands[current_player_hand]

    player_hand.bet /= 2
    player_hand.played = true
    player_hand.payed = true
    player_hand.status = Hand::Status::Lost

    @money -= player_hand.bet
    draw_hands
    bet_options
  end

  def no_insurance
    if dealer_hand.is_blackjack?
      dealer_hand.hide_down_card = false
      dealer_hand.played = true

      pay_hands
      draw_hands
      bet_options
      return
    end

    player_hand = player_hands[current_player_hand]
    if player_hand.is_done?
      play_dealer_hand
      draw_hands
      bet_options
      return
    end

    draw_hands
    player_hand.get_action
  end

  def normalize_current_bet
    if @current_bet < MIN_BET
      @current_bet = MIN_BET
    end

    if @current_bet > MAX_BET
      @current_bet = MAX_BET
    end

    if @current_bet > @money
      @current_bet = @money
    end
  end

  def pay_hands
    dhv = dealer_hand.get_value(Hand::Count::Soft)
    dhb = dealer_hand.is_busted?

    player_hands.each do |player_hand|
      next if player_hand.payed

      player_hand.payed = true
      phv = player_hand.get_value(Hand::Count::Soft)

      if dhb || phv > dhv
        if player_hand.is_blackjack?
          player_hand.bet *= 1.5
        end

        @money += player_hand.bet
        player_hand.status = Hand::Status::Won

      elsif phv < dhv
        @money -= player_hand.bet
        player_hand.status = Hand::Status::Lost

      else
        player_hand.status = Hand::Status::Push
      end
    end

    normalize_current_bet
    save_game
  end

  def bet_options
    puts " (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit"

    br = false
    while true
      case STDIN.raw &.read_char
      when 'd'
        br = true
        deal_new_hand
      when 'b'
        br = true
        get_new_bet
      when 'o'
        br = true
        game_options
      when 'q'
        br = true
        clear
      else
        br = true
        clear
        draw_hands
        bet_options
      end

      break if br
    end
  end

  def get_new_bet
    clear
    draw_hands

    puts " Current Bet: #{Game.format_money(current_bet)}"
    print " Enter New Bet: $"

    @current_bet = gets.to_s.to_i * 100.0
    normalize_current_bet

    deal_new_hand
  end

  def game_options
    clear
    draw_hands

    puts " (N) Number of Decks  (T) Deck Type  (B) Back"

    br = false
    while true
      case STDIN.raw &.read_char
      when 'n'
        br = true
        get_new_num_decks
      when 't'
        br = true
        get_new_deck_type
      when 'b'
        br = true
        clear
        draw_hands
        bet_options
      else
        br = true
        clear
        draw_hands
        game_options
      end

      break if br
    end
  end

  def get_new_num_decks
    clear
    draw_hands

    puts " Number Of Decks: #{num_decks}"
    puts " Enter New Number Of Decks: "

    new_num_decks = (STDIN.raw &.read_char).to_s.to_i
    new_num_decks = 1 if new_num_decks < 1
    new_num_decks = 8 if new_num_decks > 8
    num_decks = new_num_decks

    game_options
  end

  def get_new_deck_type
    clear
    draw_hands

    puts " (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights"

    br = false
    while true
      case STDIN.raw &.read_char
      when '1'
        br = true
        shoe.new_regular
      when '2'
        br = true
        shoe.new_aces
      when '3'
        br = true
        shoe.new_jacks
      when '4'
        br = true
        shoe.new_aces_jacks
      when '5'
        br = true
        shoe.new_sevens
      when '6'
        br = true
        shoe.new_eights
      else
        br = true
        clear
        draw_hands
        game_options
      end

      if br
        draw_hands
        bet_options
        break
      end
    end
  end

  def save_game
    file = "#{num_decks}|#{money}|#{current_bet}"
    File.write SAVE_FILE, file
  end

  def load_game
    begin
      file = File.read SAVE_FILE
    rescue
      file = ""
    end

    a = file.split("|")
    if a.size == 3
      @num_decks = a[0].to_i
      @money = a[1].to_f
      @current_bet = a[2].to_f
    end

    if money < MIN_BET
      @money = START_MONEY
      @current_bet = MIN_BET
    end
  end

  def self.format_money(money)
    "$#{sprintf("%.2f", money / 100.0)}"
  end
end
