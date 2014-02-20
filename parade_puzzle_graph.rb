require 'set'
class Node
	attr_reader :incoming, :outgoing, :data
	def initialize(data)
		@data = data
		@incoming = Set.new
		@outgoing = Set.new
	end

	def edge_to(other_node)
		self.outgoing << other_node
		other_node.incoming << self
	end

end

class Graph
	attr_reader :edges, :head_nodes, :nodes
	def initialize
		@head_nodes = Set.new
		@nodes = {}
	end

	def get_or_create(country_name)
		unless @nodes.has_key?(country_name)
			@nodes[country_name] = Node.new(country_name)
		end

		@nodes[country_name]
	end

	def tsort
		list = []
		new_head_nodes = Set.new
		until @head_nodes.empty?
			@head_nodes.each do |node_n|
				list << node_n.data
				@head_nodes.delete(node_n)
				node_n.outgoing.each do |node_m|
					node_m.incoming.delete(node_n)
					new_head_nodes << node_m if node_m.incoming.empty?
				end
			end
			@head_nodes.merge(new_head_nodes)
			new_head_nodes.clear
		end
		if @nodes.values.any?{|node| !node.incoming.empty? && !node.outgoing.empty?}
			return "Illegal request file!"
		else
			list
		end
	end

	def assert_rule(country1, country2)
		node1 = get_or_create(country1)
		node2 = get_or_create(country2)
		node1.edge_to(node2)
	end

	def add_rule(rule)
		rule, country1, order, country2 = rule.match(/(^.*)\scomes\s(\w*)\s(.*)/).to_a
		if order == "before"
			assert_rule(country1, country2)
		else
			assert_rule(country2, country1)
		end
	end

	def add_rules_from_file(file)
		IO.readlines(file).each do |line|
			add_rule(line)
		end
	end

	def build_head_nodes
		@nodes.each do |name, node|
			@head_nodes << node if node.incoming.empty?
		end
	end

end


if __FILE__ == $PROGRAM_NAME
	begin
		graph = Graph.new
		graph.add_rules_from_file(ARGV[0])
		graph.build_head_nodes
		puts graph.tsort
		p 
	end
end