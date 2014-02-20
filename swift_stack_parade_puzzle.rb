class ParadeFloat
	attr_accessor :name, :countries_following, :preceding_countries, :priority
	def initialize(country_name)
		@name = country_name
		@countries_following = []
		@preceding_countries = []
		@priority = 0
	end

	def comes_before(float)
		self.countries_following << float
		float.preceding_countries << self
	end

	def self_and_all_followers
		floats = [self]
		self.countries_following.each do |country|
			floats.concat(country.self_and_all_followers)
		end
		floats
	end

	def has_loop?
		self.countries_following.each do |country|
			return true if country.loop_helper(self)
		end

		false
	end

	def loop_helper(target)
		return true if self == target

		found = false
		self.countries_following.each do |country|
			found = country.loop_helper(target)
		end

		found
	end
end

class DataFileError < StandardError
end

class Parade
	attr_reader :levels
	def initialize
		@levels = [{}]
	end

	def get(country_name)
		@levels.each do |level|
			if level.has_key?(country_name)
				return level[country_name]
			end
		end

		nil
	end

	def remove(float)
		levels[float.priority].delete(float.name)
	end

	def add_at(float, level)
		levels[level] ||= {}
		levels[level][float.name] = float
		float.priority = level
		if level_contains_preceders?(float, level)
			push_back(float)
		end
		push_back_followers(float.countries_following, level)
	end

	def level_contains_preceders?(float, level)
		float.preceding_countries.each do |country|
			return true if levels[level].has_key?(country.name)
		end
		false
	end

	def push_back(float)
		self.remove(float)
		add_at(float, float.priority + 1)
	end

	def push_back_followers(countries, level)
		countries.each do |country|
			push_back(country) if @levels[level].has_key?(country.name)
		end
	end

	def to_s
		names = []
		levels.each do |level|
				names.concat(level.keys)
		end

		names
	end

	def add_rule(rule)
		rule, country1, order, country2 = rule.match(/(^.*)\scomes\s(\w*)\s(.*)/).to_a
		if order == "before"
			assert_x_before_y(country1, country2)
		else
			assert_x_before_y(country2, country1)
		end
	end

	def add_rules_from_file(file)
		IO.readlines(file).each do |line|
			add_rule(line)
		end
	end

	private

	def assert_x_before_y(x, y)
		float1 =  get(x)
		float2 = get(y)
		if float1 && float2
			float1.comes_before(float2)
			if float1.has_loop?
				raise DataFileError.new("Illegal request file!")
			else
				float2.self_and_all_followers.reverse.each do |f|
					if f.priority != float1.priority
						self.remove(f)
						add_at(f, float1.priority)
					end
				end
			end

		elsif float1 && float2.nil?
			float2 = ParadeFloat.new(y)
			float1.comes_before(float2)
			float2.priority = float1.priority
			add_at(float2, float1.priority)

		elsif float2 && float1.nil?
			float1 = ParadeFloat.new(x)
			float1.comes_before(float2)
			float1.priority = float2.priority
			add_at(float1, float2.priority)

		else
			f1, f2 = ParadeFloat.new(x), ParadeFloat.new(y)
			f1.comes_before(f2)
			add_at(f1, 0)
			add_at(f2, 0)
		end
	end

end

if __FILE__ == $PROGRAM_NAME
	begin
		parade = Parade.new
		parade.add_rules_from_file(ARGV[0])
	rescue DataFileError => e
		puts e
	else
		puts parade.to_s
	end
end

