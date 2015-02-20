require 'pry'
require 'sinatra'
require 'httparty'
require 'json'
require 'json2csv'
require 'twitter'
require 'csv'

set :server, 'webrick'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    puts max_id
    options = {count: 200, include_rts: false}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

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
  super_array.delete("")
  super_array.delete("""")
  super_array.delete("as")
  super_array.delete("by")
  super_array.delete("not")
  super_array.delete("and")
  super_array.delete("some")
  super_array.delete("get")
  super_array.delete("up")
  super_array.delete("your")
  super_array.delete("i")
  super_array.delete("me")
  super_array.delete("my")
  super_array.delete("have")
  super_array.delete("get")
  super_array.delete("got")
  super_array.delete("me")
  super_array.delete("was")
  super_array.delete("be")
  super_array.delete("am")
  super_array.delete("about")
  super_array.delete("no")
  super_array.delete("our")
  super_array.delete("cant")
  super_array.delete("wont")
  super_array.delete("or")
  super_array.delete("that")
  super_array.delete("thats")
  super_array.delete("come")
  super_array.delete("comes")
  super_array.delete("so")
  counts = Hash.new 0
  counts_array = []
  super_array.each do |word|
    counts[word] += 1
  end
  counts.each do |key, value|
    counts_array.push({name: key, count: value})
  end
  sorted = counts_array.sort_by { |v| -v[:count] }
  sorted.take(100)
end

get '/' do 
	erb :index
end

post '/search' do
  tweet_text = []
  client.get_all_tweets(params["handle"]).each do |x|
    tweet_text.push(x.full_text)
  end
  response = combine(tweet_text)
  csv_response = CSV.generate do |csv|
    csv << ["name", "count"]
    response.each do |tweet|
      csv << [tweet[:name], tweet[:count]]
    end
  end
	erb :results, locals: {csv_response: csv_response, handle: params["handle"]}
end

