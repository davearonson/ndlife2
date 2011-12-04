#! /usr/bin/ruby -w

require './ndlife.rb'
include NDLife


clearer = $stdout.isatty ? "\e[H\e[2J" : ''

puts "#{clearer}Creating the world...."
w = World.new :dimensions => [5,5,10,20]
new_dump = w.dump
old_dump = 'this is not a valid dump'


gen_num = 1
calc_time = 0
calc_tot = 0
cell_tot = 0
dumps = []
prev_idx = nil
until w.cells.empty? || prev_idx do
  cell_tot += w.cells.length
  puts "#{clearer}Generation #{gen_num} (#{w.cells.length} cells)"
  print new_dump
  dumps << new_dump
  gen_num += 1
  timer = Time.now
  w.turn
  calc_time = Time.now - timer
  calc_tot += calc_time
  old_dump = new_dump
  new_dump = w.dump
  prev_idx = dumps.find_index new_dump
end
puts
if w.cells.empty?
  puts 'All dead....'
else
  puts "Stability reached!  Generation #{gen_num} is the same as generation #{prev_idx + 1}"
end
puts "Calculation time averaged #{'%1f' % (calc_tot / cell_tot)}"
