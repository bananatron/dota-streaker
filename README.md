<b>Dota streaker</b> is a web app which uses the Steam API to detect Win/Loss streaks.


<b>Tech Details</b><br>
Dotastreaker is a ruby/sinatra app which makes two series of API calls - one to get a match list for the player, and then another to get the match details for the last X (currently 8) matches to determine the win results for those matches.

It then takes the converted steam ID and finds the team they were on in order to compare that to the winning team of the match and results the output, with a snarky/complementary remark below it. No information is cached so it's live up to the second.

This is my first ruby app so don't trust that this is the best way to do things.
