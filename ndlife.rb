#! /usr/bin/ruby -w

require 'set'

module NDLife

  class World

    # use these constants 'cuz I'm planning to expand range of species.
    # yes that means that later i won't be able to use sets, but will
    # need a hash containing what's at that place.
    ALIVE = true
    DEAD = false

    attr_reader :cells, :dimensions,
                :max_nbrs_to_be_born, :min_nbrs_to_be_born,
                :max_nbrs_to_survive, :min_nbrs_to_survive,
                :neighbor_vectors

    def initialize args = { :dimensions => [4,4,4,4,4,4] }

      @dimensions = args[:dimensions] || []

      state = args[:state]

      @cells = state ? absorb_layer(state, 0) : Set.new

      pctAlive = args[:pctAlive] || 25

      if @dimensions && ! state
        tomake = @dimensions.inject(:*) * pctAlive / 100
        while @cells.length < tomake do
          coords = []
          @dimensions.length.times do |i|
            coords[i] = (rand * @dimensions[i]).floor
          end
          @cells << coords
        end
      end

      part = (3 ** @dimensions.length - 1) / 8
      @max_nbrs_to_be_born = args[:max_born] || (2.75 * part).round
      @min_nbrs_to_be_born = args[:min_born] || (2.50 * part).round
      @max_nbrs_to_survive = args[:max_surv] || (3.00 * part).round
      @min_nbrs_to_survive = args[:min_surv] || (1.50 * part).round

      @neighbor_vectors = make_neighbor_vectors(@dimensions.length).delete_if { |vector|
        vector.all? { |coord| coord == 0 }
      }

      @neighbor_cache = {}
    end

    # TODO MAYBE: make it barf if wrong # of dimensions, or out of bounds
    def count_neighbors center, options = {}
      neighbor = []
      total = 0
      dead_list = options[:dead_list]
      max = options[:max]

      neighbors = @neighbor_cache[center]
      if neighbors.nil?
        neighbors = []
        @neighbor_vectors.each do |vector|
          # too slow (about three times as long!) to do:
          # neighbor = center.zip(vector).map{|a|a.inject(:+)}.flatten.zip(@dimensions).map{|a|a.inject(:%)}.flatten
          # not to mention a lot less clear!
          neighbor = []
          center.length.times do |idx|
            neighbor[idx] = (center[idx] + vector[idx]) % @dimensions[idx]
          end
          neighbors << neighbor if neighbor != center  # possible if any dimension == 1
        end
        @neighbor_cache[center] = neighbors
      end

      # do this semi-procedurally so we can return early!
      total = 0
      neighbors.each{ |neighbor|
        if @cells.include? neighbor
          total += 1
          # technically this could yield an incorrect count, AND skip some
          # cells that should be added to the dead-list, but not in
          # circumstances where we care; it should only be used to return early
          # from checking if a dead cell can come alive, once we have too many.
          return total if max && total >= max
        elsif dead_list
          dead_list << neighbor
        end
      }
      total
    end

    def dump
      dump_layer [], @dimensions
    end

    # this could be rearranged to be "tighter" LOOKING, but
    # it actually slows it down, from ~5us to ~8us per cell!
    def next_cell_state old_state, num_nbrs
      if old_state == ALIVE
        if num_nbrs < @min_nbrs_to_survive || num_nbrs > @max_nbrs_to_survive
          DEAD
        else
          ALIVE
        end
      else
        if num_nbrs < @min_nbrs_to_be_born || num_nbrs > @max_nbrs_to_be_born
          DEAD
        else
          ALIVE
        end
      end
    end

    def turn
      new_cells = Set.new
      dead_nbrs = Set.new
      @cells.each do |coords|
        if next_cell_state(ALIVE,
                           count_neighbors(coords,
                                           :dead_list => dead_nbrs)) == ALIVE
          new_cells << coords
        end
      end
      # TODO: sanity check: live + dead should = # of possible neighbors
      dead_nbrs.each do |coords|
        if next_cell_state(DEAD, count_neighbors(coords,
                                                 :max => (@max_nbrs_to_be_born + 1))) == ALIVE
          new_cells << coords
        end
      end
      @cells = new_cells
      self
    end

    private

      def absorb_layer arr, layer_num
        ret = Set.new
        if arr.kind_of? String
          arr.length.times do |idx|
            # use idx..idx, not just idx, so as to be 1.8-compatible :-P
            ret << [idx] if arr[idx..idx] == '*'
          end
        else
          arr.each_index do |idx|
            absorb_layer(arr[idx], (layer_num + 1)).each do |coords|
              ret << (coords.unshift idx)
            end
          end
        end
        @dimensions[layer_num] = [@dimensions[layer_num].to_i, arr.length].max
        ret
      end

      def dump_layer coords_so_far, dims_left
        if dims_left.empty?
          return (@cells.include? coords_so_far) ? '*' : ' '
        end
        sub_rets = (0..(dims_left[0]-1)).map { |idx|
          dump_layer(coords_so_far.clone << idx, dims_left[1..-1])
        }
        if dims_left.length == 1
          ret = sub_rets.join ''
        elsif dims_left.length == 2
          ret = sub_rets.join "\n"
        elsif dims_left.length % 2 == 1
          ret = sub_rets.map{|a|a.split "\n"}.inject(&:zip).
            map(&:flatten).map{|a|a.join('|')}.join("\n")
        else
          line_len = sub_rets[0].split("\n")[0].length
          ret = sub_rets.join("\n" + '-' * line_len + "\n")
        end
        ret
      end

      def make_neighbor_vectors num_dims
        if num_dims == 0
          [[]]
        else
          subs = make_neighbor_vectors(num_dims - 1)
          (-1..1).map { |delta|
            subs.map { |vector| vector.clone << delta }
          }.flatten(1)
        end

      end

    # end of private section

  end

end
