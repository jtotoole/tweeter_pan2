require 'pry'
require 'httparty'
require 'json'
require 'json2csv'
require 'twitter'
require 'csv'


def combine (array_of_strings)
	super_array = []
	array_of_strings.each do |string|
		string_array = string.split(" ")
		string_array.each do |word|
			word = word.downcase.gsub(/[^a-z0-9\s]/i, '')
			super_array.push(word)
		end
	end
	super_array.delete("a")
	super_array.delete("an")
	super_array.delete("of")
	super_array.delete("the")
	super_array.delete("at")
	super_array.delete("it")
	super_array.delete("he")
	super_array.delete("she")
	super_array.delete("they")
	super_array.delete("them")
	super_array.delete("then")
	super_array.delete("than")
	super_array.delete("its")
	super_array.delete("to")
	super_array.delete("for")
	super_array.delete("from")
	super_array.delete("with")
	super_array.delete("is")
	super_array.delete("in")
	super_array.delete("on")
	super_array.delete("out")
	super_array.delete("are")
	super_array.delete("was")
	super_array.delete("rt")
	counts = Hash.new 0
	counts_array = []
	super_array.each do |word|
		counts[word] += 1
	end
	counts.each do |key, value|
		counts_array.push({name: key, count: value})
	end
	sorted = counts_array.sort_by { |v| -v[:count] }
	sorted = sorted.take(5)
	CSV.generate do |csv|
		csv << ["name", "count"]
		sorted.each do |tweet|
			csv << [tweet[:name], tweet[:count]]
		end
	end
end


array = ["Hey what's james james go stop hell james joe joe joe joe joe up YOU", "Yo yo yo a with an hi", "hi! how are you?"]
puts combine(array)
