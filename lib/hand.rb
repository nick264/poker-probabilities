class Hand
  attr_accessor :hole, :community

  def initialize(hole,community = [])
    raise "Two hole cards required" unless hole.size == 2
    @hole = hole
    @community = community
  end

  def hands
    [
      :straight_flush,
      :four_of_a_kind,
      :full_house,
      :flush,
      :straight,
      :three_of_a_kind,
      :two_pair,
      :pair,
      :high_card
    ]
  end

  def best_hand
    hands.each_with_index do |h,i|
      result = self.send("#{h}?")
      return( [h, i + 1, result[1] ]) if result[0]
    end

    false
  end

  def straight_flush?
    if ( s = straight? )[0] && flush?[0]
      [ true, s[1] ]
    else
      [ false, nil ]
    end
  end

  def flush?
    uniq_hole_suits = hole.map(&:suit).uniq
    return [ false, nil ] if uniq_hole_suits.size > 1

    if ( matching_community = community.select{ |x| x.suit == uniq_hole_suits[0] } ).size >= 3
      [ true, ( matching_community.map(&:rank_as_i) + hole.map(&:rank_as_i) ).max ]
    else
      [ false, nil ]
    end
  end

  def straight?
    ranks = hole.map(&:rank_as_i) + community.map(&:rank_as_i)
    
    ranks_sorted = ranks.sort.uniq

    run = [ ranks_sorted[0] ]
    ranks_sorted[1..-1].each do |r|
      if r != run.last + 1
        run = []
      end

      run << r

      # true if run of five and both hole cards are part of the run
      return( [ true, run.max ] ) if run.size == 5 && ( run - [hole[0].rank_as_i] - [hole[1].rank_as_i] ).size == 3
    end

    [ false, nil ]
  end

  def three_of_a_kind?
    if ( trips = ranks_by_count.select{ |x,y| y == 3 } ).present?
      return( [ true, trips.sort_by{ |x,y| x }.last[0] ] )
    else
      return( [ false, nil ] )
    end
  end

  def pair?
    if ( pairs = ranks_by_count.select{ |x,y| y == 2 } ).size == 1
      pair_rank = pairs.sort_by{ |x,y| x }.last[0]
      return( [ true, pair_rank ] )
    else
      return( [ false, nil ] )
    end
  end

  def two_pair?
    if ( pairs = ranks_by_count.select{ |x,y| y == 2 } ).size > 1
      two_pair_ranks = pairs.map(&:first).sort[0..1]
      return( [ true, significance_score(two_pair_ranks) ] )
    end

    return( [ false, nil ] )
  end

  def full_house?
    triples = ranks_by_count.select{ |x,y| y == 3 }.sort_by(&:first)
    doubles = ranks_by_count.select{ |x,y| y == 2 }.sort_by(&:first)

    return( [ false, nil ] ) if triples.empty?

    triple_ranks_ordered = triples.map(&:first).reverse
    double_ranks_ordered = doubles.map(&:first).reverse
    leftover_hole_ranks = hole.map(&:rank_as_i)

    triple_ranks_ordered.each do |tr|
      other_pairs_ordered = ( double_ranks_ordered + ( triple_ranks_ordered - [tr] ) ).sort.reverse
      other_pairs_ordered.each do |dr|
        if ( leftover_hole_ranks - [tr] - [dr] ).empty?
          return( [ true, significance_score([tr,dr]) ] )
        end
      end
    end

    return( [ false, nil ] )
  end

  def four_of_a_kind?
    quads = ranks_by_count.select{ |x,y| y == 4 }

    if quads.empty?
      return( [ false, nil ] )
    else
      next_highest = if( leftover_hole = ( hole.map(&:rank_as_i) - [quads[0][0]] ) ).present?
        leftover_hole[0]
      else
        ( community.map(&:rank_as_i) - quads[0][0] ).sort.last
      end

      return( [ true, significance_score([quads[0][0], next_highest]) ] )
    end
  end

  def high_card?
    highest_card = ( hole + community ).map(&:rank_as_i).max
    return( [ true, highest_card ] )
  end

  def ranks_by_count
    all_ranks = hole.map(&:rank_as_i) + community.map(&:rank_as_i)

    ranks_by_count = ( hole + community ).group_by{ |x| x.rank_as_i }.map{ |x,y| [ x, y.size ] }
  end

  def significance_score(ranks_by_significance)
    total_ranks = Card.ranks.size

    retval = 0
    ranks_by_significance.reverse.each_with_index.map do |r,i|
      retval += r * total_ranks ** i
    end

    retval
  end
end