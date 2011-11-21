#! /usr/bin/ruby -w

module NDLife

  require 'set'

  class World

    # use these constants 'cuz I'm planning to expand range of species.
    # yes that means that later i won't be able to use sets, but will
    # need a hash containing what's at that place.
    ALIVE = true
    DEAD = false

    attr_reader :cells, :dimensions,
                :max_nbrs_to_be_born, :min_nbrs_to_be_born,
                :max_nbrs_to_survive, :min_nbrs_to_survive

    def initialize args = { :dimensions => [4,4,4,4,4,4] }
      state = args[:state]

      @dimensions = args[:dimensions] || []

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
    end

    # TODO MAYBE: make it barf if wrong # of dimensions, or out of bounds
    def count_neighbors coords, options = {}
      count_neighbors_layer coords, [], options
    end

    def dump
      dump_layer [], @dimensions
    end

    # this could be rearranged to be "tighter" LOOKING, but
    # it actually slows it down, from ~5ms to ~8ms per cell!
    def next_cell_state old_state, num_nbrs
      if old_state == ALIVE
        if num_nbrs < min_nbrs_to_survive
          DEAD
        elsif num_nbrs > max_nbrs_to_survive
          DEAD
        else
          ALIVE
        end
      else
        if num_nbrs < min_nbrs_to_be_born
          DEAD
        elsif num_nbrs > max_nbrs_to_be_born
          DEAD
        else
          ALIVE
        end
      end
    end

    def next_state
      new_cells = Set.new
      dead_neighbors = Set.new
      @cells.each do |coords|
        if next_cell_state(ALIVE,
                           count_neighbors(coords,
                           :dead_neighbors => dead_neighbors)) == ALIVE
          new_cells << coords
        end
      end
      dead_neighbors.each do |coords|
        if next_cell_state(DEAD,
                           count_neighbors(coords,
                          :max_neighbor_count => @max_nbrs_to_be_born)) == ALIVE
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
        @dimensions[layer_num] = 0 if ! @dimensions[layer_num]
        @dimensions[layer_num] = [@dimensions[layer_num], arr.length].max
        ret
      end

      # Bit of a kluge -- count the neighbors, AND if the dead_neighbors arg is
      # not nil, add any we find (see next_state for why), grossly violating
      # Single Responsibility, PLUS if we have a max number of neighbors to
      # look for, return immediately upon finding them, not bothering to count
      # any more.  Why such kluges?  Speed....
      def count_neighbors_layer center, neighbor, options = {}
        if neighbor.length == center.length
          if @cells.include? neighbor
            (neighbor != center) ? 1 : 0
          else
            dead_neighbors = options[:dead_neighbors]
            dead_neighbors << neighbor if dead_neighbors
            0
          end
        else
          layer = neighbor.length
          max_neighbor_count = options[:max_neighbor_count] 
          (-1..1).reduce(0) do |sofar, delta|
            next_coord = (center[layer] + delta) % @dimensions[layer]
            sofar += count_neighbors_layer center,
                                           (neighbor.clone << next_coord),
                                           options
            return sofar if (max_neighbor_count && sofar >= max_neighbor_count)
            sofar
          end
        end
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

    # end of private section

  end

end
