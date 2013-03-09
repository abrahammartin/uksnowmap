require 'rubygems'
require 'eventmachine'

require 'twitter'

POSTAL_MATCHER = / ([A-Z]{1,2}[0-9][0-9A-Z]?) /i
SCORE_MATCHER  = /(\d{1,2})\/(\d{2})/

def filter_for_uk_snow( tweets )
  found_uk_snow = []
  tweets.each do | t |
    postal_district = t.text.match POSTAL_MATCHER
    score = t.text.match SCORE_MATCHER
    if postal_district and score
      found_uk_snow << {
        :tw_id  => t.id_str,
        :score  => score[0],
        :postal => postal_district[0].upcase
      }
    end
  end
  found_uk_snow
end

require './rb/backend'

EM::run do
  EM.add_periodic_timer(30) do 
    begin
      uk_snow_tweets = Twitter.search("#uksnow").results
      tweets = filter_for_uk_snow( uk_snow_tweets )
      p tweets
      Backend::store(tweets)
    rescue Exception=>e
     puts 'There was a problem'
    end
  end
end
puts "Finished."