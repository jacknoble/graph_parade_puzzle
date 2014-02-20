graph_parade_puzzle
===================

Two solutions for the SwiftStack parade puzzle.

The puzzle is at https://swiftstack.com/jobs/puzzles/parade/

The first solution is in swift_stack_parade_puzzle.rb, I made it before reading about graph theory and learning the classic
solution to this sort of problem. I'm pretty proud of it as it is totally original-- though it is complicated enough that 
I'm not sure about it's time complexity, should be linear.

The second solution is in parade_puzzle_graph.rb which creates a directed graph, sorts it topologically returning the
appropriate error message if the graph has cycles. It is linear and is probably the superior solution.

Both can be run as scripts taking a properly formatted data file as an argument.
