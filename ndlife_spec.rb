#! /usr/bin/env ruby

require './ndlife.rb'
include NDLife

describe 'NDLife' do

  describe 'absorbs correctly' do

    it 'absorbs 1d empty right' do
      World.new(state: '').cells.should == Set.new
    end

    it 'absorbs 1d dead right' do
      World.new(state: ' ').cells.should == Set.new
    end

    it 'absorbs 1d pattern right' do
      World.new(state: '* * *').cells.should == Set[[0], [2], [4]]
    end

    it 'absorbs 1d single right' do
      World.new(state: '*').cells.should == Set[[0]]
    end

    it 'absorbs 2d empty right' do
      World.new(state: ['']).cells.should == Set.new
    end

    it 'absorbs 2d dead right' do
      World.new(state: [' ']).cells.should == Set.new
    end

    it 'absorbs 2d single right' do
      World.new(state: ['*']).cells.should == Set[[0,0]]
    end

    it 'absorbs 2d row right' do
      World.new(state: ['* * *']).cells.should == Set[[0,0], [0,2], [0,4]]
    end

    it 'absorbs 2d grid correctly' do
      init_state = [' * ',
                    '* *',
                    '*  ']
      world = World.new state: init_state
      world.cells.should == Set[[0,1], [1,0], [1,2], [2,0]]
    end

  end

  describe 'figures out dimensions' do

    it 'empty one-dimension' do
      world = World.new state: ''
      world.dimensions.should == [0]
    end

    it 'single dead one-dimension' do
      world = World.new state: ' '
      world.dimensions.should == [1]
    end

    it 'single live one-dimension' do
      world = World.new state: '*'
      world.dimensions.should == [1]
    end

    it 'empty two-dimension' do
      world = World.new state: ['']
      world.dimensions.should == [1,0]
    end

    it 'single dead two-dimension' do
      world = World.new state: [' ']
      world.dimensions.should == [1,1]
    end

    it 'single live two-dimension' do
      world = World.new state: ['*']
      world.dimensions.should == [1,1]
    end

    it 'two-dimension grid' do
      world = World.new state: ['   ', '   ']
      world.dimensions.should == [2,3]
    end

    it 'three-dimension' do
      world = World.new state: [['    ', '    ', '    ' ],
                                ['    ', '    ', '    ' ]]
      world.dimensions.should == [2,3,4]
    end

  end

  describe 'gets the same limits as standard in 2d' do

    it 'calculates max to be born' do
      World.new(dimensions: [10,10]).max_nbrs_to_be_born.should == 3
    end

    it 'calculates min to be born' do
      World.new(dimensions: [10,10]).min_nbrs_to_be_born.should == 3
    end

    it 'calculates max to survive' do
      World.new(dimensions: [10,10]).max_nbrs_to_survive.should == 3
    end

    it 'calculates min to survive' do
      World.new(dimensions: [10,10]).min_nbrs_to_survive.should == 2
    end

  end


  describe 'enforces the rules' do

    it 'cell dies with too few neighbors' do
      w = World.new dimensions: [10,10]
      w.next_cell_state(World::ALIVE,
                        w.min_nbrs_to_survive - 1).should == World::DEAD
    end

    it 'cell survives with just enough neighbors' do
      w = World.new dimensions: [10,10]
      w.next_cell_state(World::ALIVE,
                        w.min_nbrs_to_survive).should == World::ALIVE
    end

    it 'cell survives with just few enough neighbors' do
      w = World.new dimensions: [10,10]
      w.next_cell_state(World::ALIVE,
                        w.max_nbrs_to_survive).should == World::ALIVE
    end

    it 'cell dies with too many neighbors' do
      w = World.new dimensions: [10,10]
      w.next_cell_state(World::ALIVE,
                        w.max_nbrs_to_survive + 1).should == World::DEAD
    end

  end

  describe 'dumps correctly' do

    it 'null' do
      state = ''
      World.new(state: state).dump.should == state
    end

    it 'one dead' do
      state = ' '
      World.new(state: state).dump.should == state
    end

    it 'one live' do
      state = '*'
      World.new(state: state).dump.should == state
    end

    it 'a string' do
      state = '* * *'
      World.new(state: state).dump.should == state
    end

    it 'a grid' do
      state = ['* * *',
               ' * * ',
               '  *  ']
      World.new(state: state).dump.should == state.join("\n")
    end

    it '3d' do
      state = [['*  *',
                ' ** ',
                '    '],
                      ['    ',
                       ' ** ',
                       '*  *'],
                             ['*  *',
                              ' ** ',
                              '    ']]
      World.new(state: state).dump.should ==
              "*  *|    |*  *\n" +
              " ** | ** | ** \n" +
              "    |*  *|    "
    end

    it '4d' do
      state = [[['*  *',
                 ' ** ',
                 '    '],
                       ['    ',
                        ' ** ',
                        '*  *'],
                              ['*  *',
                               ' ** ',
                               '    ']],
               [['    ',
                 ' ** ',
                 '*  *'],
                       ['*  *',
                        ' ** ',
                        '*  *'],
                              ['    ',
                               ' ** ',
                               '*  *']],
               [['*  *',
                 ' ** ',
                 '    '],
                       ['    ',
                        ' ** ',
                        '*  *'],
                              ['*  *',
                               ' ** ',
                               '    ']]]
      World.new(state: state).dump.should ==
              "*  *|    |*  *\n" +
              " ** | ** | ** \n" +
              "    |*  *|    \n" +
              "--------------\n" +
              "    |*  *|    \n" +
              " ** | ** | ** \n" +
              "*  *|*  *|*  *\n" +
              "--------------\n" +
              "*  *|    |*  *\n" +
              " ** | ** | ** \n" +
              "    |*  *|    "
    end

    it '5d' do
      state = [[[['* * *', '*****', '  *  '], ['  *  ', ' * * ', '  *  '], ['* * *', ' * * ', '  *  ']],
                [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *']]],
               [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']]],
               [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']]],
               [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', ' *** ']]]]
      World.new(state: state).dump.should ==
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              "*****| * * | * * | * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |  *  |  *  |  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              "-----------------|-----------------|-----------------|-----------------\n" +
              "  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *\n" +
              "-----------------|-----------------|-----------------|-----------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |* * *|* * *|  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *| *** "
    end

    it '6d' do
      state = [[[[['* * *', '*****', '  *  '], ['  *  ', ' * * ', '  *  '], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', ' *** ']]]],
               [[[['* * *', '** **', '  *  '], ['  *  ', ' * * ', '  *  '], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', ' *** ']]]],
               [[[['* * *', '*****', '  *  '], ['  *  ', ' * * ', '  *  '], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', ' *** ']]]],
               [[[['* * *', '** **', '  *  '], ['  *  ', ' * * ', '  *  '], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']]],
                [[['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '  *  ']],
                 [['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', '* * *'], ['  *  ', ' * * ', '* * *']],
                 [['* * *', ' * * ', '  *  '], ['  *  ', ' * * ', '* * *'], ['* * *', ' * * ', ' *** ']]]]]
      World.new(state: state).dump.should ==
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              "*****| * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |  *  |  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              "-----------------|-----------------|-----------------\n" +
              "  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *\n" +
              "-----------------|-----------------|-----------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |* * *|* * *|  *  |* * *|  *  |  *  |* * *| *** \n" +
              "-----------------------------------------------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              "** **| * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |  *  |  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              "-----------------|-----------------|-----------------\n" +
              "  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *\n" +
              "-----------------|-----------------|-----------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |* * *|* * *|  *  |* * *|  *  |  *  |* * *| *** \n" +
              "-----------------------------------------------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              "*****| * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |  *  |  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              "-----------------|-----------------|-----------------\n" +
              "  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *\n" +
              "-----------------|-----------------|-----------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |* * *|* * *|  *  |* * *|  *  |  *  |* * *| *** \n" +
              "-----------------------------------------------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              "** **| * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |  *  |  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              "-----------------|-----------------|-----------------\n" +
              "  *  |* * *|  *  |  *  |* * *|  *  |  *  |* * *|  *  \n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *|* * *\n" +
              "-----------------|-----------------|-----------------\n" +
              "* * *|  *  |* * *|* * *|  *  |* * *|* * *|  *  |* * *\n" +
              " * * | * * | * * | * * | * * | * * | * * | * * | * * \n" +
              "  *  |* * *|* * *|  *  |* * *|  *  |  *  |* * *| *** "
    end

  end

  describe "counts neighbors" do

    it 'null' do
      # not applicable since we can't specify the coordinates!
    end

    it 'one dead' do
      World.new(state: ' ').count_neighbors([0]).should == 0
    end

    it 'one live' do
      # zero 'cuz it knows better than to count cell as own neighbor!
      World.new(state: '*').count_neighbors([0]).should == 0
    end

    it 'solo live on end of a string' do
      World.new(state: '* ').count_neighbors([0]).should == 0
    end

    it 'solo dead on end of a string' do
      World.new(state: '* ').count_neighbors([1]).should == 2
    end

    it 'string of two alive' do
      # two 'cuz it DOESN'T know better than to count a neighbor
      # cell twice, due to being in different directions.
      # yes, i know i am now violating "one test per example", screw it....
      w = World.new(state: '**')
      w.count_neighbors([0]).should == 2
      w.count_neighbors([1]).should == 2
    end

    it 'string of two dead' do
      w = World.new(state: '  ')
      w.count_neighbors([0]).should == 0
      w.count_neighbors([1]).should == 0
    end

    it 'string of three with dead ends' do
      w = World.new(state: ' * ')
      w.count_neighbors([0]).should == 1
      w.count_neighbors([1]).should == 0
      w.count_neighbors([2]).should == 1
    end

    it 'string of three with live ends' do
      w = World.new(state: '* *')
      w.count_neighbors([0]).should == 1
      w.count_neighbors([1]).should == 2
      w.count_neighbors([2]).should == 1
    end

    it 'a grid' do
      w = World.new(state: ['* *',
                            ' * ',
                            '** '])
      w.count_neighbors([0,0]).should == 4
      w.count_neighbors([0,1]).should == 5
      w.count_neighbors([0,2]).should == 4
      w.count_neighbors([1,0]).should == 5
      w.count_neighbors([1,1]).should == 4
      w.count_neighbors([1,2]).should == 5
      w.count_neighbors([2,0]).should == 4
      w.count_neighbors([2,1]).should == 4
      w.count_neighbors([2,2]).should == 5
    end

    it '3d' do
      pending
    end

    it '4d' do
      pending
    end

    it '5d' do
      pending
    end

    it '6d' do
      pending
    end

  end

end
