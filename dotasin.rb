require 'json'
require 'open-uri'
require 'openssl'
require 'bundler/setup'

=begin

lobby_type - the type of lobby
5 = Team match.*
4 = Co-op with bots.
3 = Tutorial.
2 = Tournament.
1 = Practice.
0 = Public matchmaking.*
-1 = Invalid.
(We only want 0 and 5)

=end


def FetchWin(aim)

	buffer = open(aim, "UserAgent" => "Ruby-Wget").read
	match_result = JSON.parse(buffer)
	match_result = match_result["result"]
	$radiant_win = match_result["radiant_win"]
	$lobby_type = match_result["lobby_type"]

#Excluding cases where the match isn't returning true or false if API 
#is being weird because that will fuck up everything - Also only want
#lobby_type of 0 or 5
	if [0, 2, 5].include?($lobby_type)
		case $radiant_win
			when true, false 
				return $radiant_win
		else
				return "No data"
		end
	end
end

#First number 7443 is my 64 bit steam ID.
#Account ID 46481715 is mine
$bit_id = 76561198006747443 - 76561197960265728
$master_id = 37934158

url = "http://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?account_id=#{$master_id}&matches_requested=6&key=7D73411819A2393855610A2F45648EC2"
buffer = open(url, "UserAgent" => "Ruby-Wget").read

result = JSON.parse(buffer)
result = result["result"]
matches = result["matches"]

#Match_id pulls in list of match ids in total
match_id = []
#Players pulls in player data
players = []
	matches.map do |x|
		match_id << x["match_id"]      
		players << x["players"]
	end

#Playerdata drills into players and returns data relevant to your $master_id	 
playerdata = []
players.map do |p|

tempvar = p
 tempvar.map do |t|

	if t["account_id"] == $master_id
		tempvar2 = t
		playerdata << tempvar2
	end
	end
end

team_table = []
#Determine if player was on radiant (true) or dire (false)
#Then compare this to match detail api to compare if dire or radiant won match
playerdata.map! do |x|
	x.each do |k, v|
			if k == "player_slot"
				if v > 100
					x[k] = false
					team_table << false
				else
					x[k] = true
					team_table << true
				end
			end
		end
	end

#Puts match_ids and teams in a hash for comparison later 
win_table = Hash[match_id.zip(team_table)]

win_results = []
match_id.each do |x|
  temp_url = "http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/V001/?match_id=#{x}&key=7D73411819A2393855610A2F45648EC2"
  win_results << FetchWin(temp_url)
end

#This output will be stored for final page to review the most recent wins/losses
winloss_output = []
#Will calculate final streak w/ integers
win_counter = []
combine = win_results.zip(team_table)

combine.each do |x, y|
	if x == y
		winloss_output << "WIN"
		win_counter << 1
		else
		winloss_output << "LOSS"
		win_counter << 0
	end
end

#win_counter stores array of 1s (wins) and 0 (losses) in sequential order to 
#determine win/loss streak because idk another way to do it. output to win_streak

base_count = win_counter[0] + win_counter [1]

streak_count = 0
#Winning streak
if base_count == 2
	win_counter.each do |w|
		if w == 1
			streak_count += 1
			else
			break 
		end
	end
	puts "You're on a #{streak_count} game winning streak."
end

#Losing streak
if base_count == 0
	win_counter.each do |l|
		if l == 0
			streak_count += 1
			else
			break
		end
	end
	puts "You're on a #{streak_count} game losing streak."
end

#No streak
if base_count == 1
	puts "You aren't on a streak yet."
end


####test output####
#f = File.new("results2.txt", "w+")
#f.write(players)

#now need to pull from other file to compare vs. win_table hash
#will want to output winloss_output on last page


puts winloss_output

