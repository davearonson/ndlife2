#! /usr/bin/ruby -w

require './ndlife.rb'
include NDLife


w = World.new :dimensions => [4,4,4,4,4,4]
new_dump = w.dump
old_dump = 'this is not a valid dump'


gen_num = 1
clearer = $stdout.isatty ? "\e[H\e[2J" : ''
calc_time = 0
calc_tot = 0
cell_tot = 0
dumps = []
until w.cells.empty? || new_dump == old_dump || dumps.include?(new_dump) do
  cell_tot += w.cells.length
  puts "#{clearer}Generation #{gen_num} (#{w.cells.length} cells)"
  # puts "(#{w.cells.length} cells @ #{'%.2f' % calc_time} seconds = #{'%.1f' % (calc_time * 1000 / w.cells.length)} ms/cell)"
  puts new_dump
  dumps << new_dump
  gen_num += 1
  timer = Time.now
  w.next_state
  calc_time = Time.now - timer
  calc_tot += calc_time
  old_dump = new_dump
  new_dump = w.dump
end
if w.cells.empty?
  puts 'All dead....'
else
  puts "Stability reached!  Generation #{gen_num} is the same as generation #{dumps.find_index new_dump}"
end
# puts "Calculation time averaged #{'%1f' % (calc_tot / cell_tot)}"
