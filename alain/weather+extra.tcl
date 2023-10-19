######################
# @UniBG irc.chatpat.bg       #
# @FreeUniBG irc.interbg.org     #   
# Credits: MeMoreX & SpiKe^^    #
# Est: 01\2022             #
######################

namespace eval Visualcrossing {
   ### Requirements
   package require json
   package require tls
   package require http

   ### Binding
   bind PUB -|- !g ::Visualcrossing::group_weather   
   bind PUB -|- !w ::Visualcrossing::pub_weather
   bind PUB -|- !3 ::Visualcrossing::forecast_weather
   bind PUB -|- !ww ::Visualcrossing::world_weather

   
 
   ### The API Keys
   #OpenWeather @ https://openweathermap.org/
   set appid "99ebeb16d27882cdd6df6fc944613f80"
   #IpGeoLocation @ https://ipgeolocation.io/signup.html
   set apiKey "6b0587f490ee4c6786f9b24973826c5a"
   #Visualcrossing @ https://visualcrossing.com/sign-up
   set key "77XX9MDETQ5GHHAHEPFK8W2S4"
   
   ### Procedures start here
proc ::Visualcrossing::download_weather {url} {
    ::http::register https 443 [list ::tls::socket -tls1 1]
   ::http::config -useragent "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
   set socket [http::geturl $url -timeout 5000]
   set items_data [http::data $socket]
   if {[http::status $socket] ne "ok" || [http::ncode $socket] != 200} {
      set code [http::code $socket]
      putlog "\00304***\003 Weather HTTP error: $code"
      putlog "\00304***\003 Request url is: $url"
      http::cleanup $socket
      return 0
    }
   http::cleanup $socket
   return $items_data
}

   ### The Main Proc
proc ::Visualcrossing::pub_weather {nick uhost hand chan arg} {
   set items_data [::Visualcrossing::download_weather https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/weatherdata/forecast?[::http::formatQuery location $arg aggregateHours 24 forecastdays 3 includeAstronomy true locationMode lookup unitGroup metric shortColumnNames false contentType json alertLevel event lang en nonulls true key $::Visualcrossing::key]]
   if {$arg == ""} { putserv "PRIVMSG $chan :Syntax: !w city/location" ; return }
   
   ### The Main Dict
   set connect   [::json::json2dict $items_data]
   
   ### The First Stack
   set locations [dict get $connect locations]
   set cityname [lindex $locations 0]
   set citydata [lindex $locations 1]
   set tz [dict get $citydata tz]
   set long [dict get $citydata longitude]
   set lat [dict get $citydata latitude]

   ### The Second Stack
   set current [dict get $citydata currentConditions]
   if {$current != "null"} { set conditions $current }
   if {$current == "null" || $current == "" || $current == " "} { set currCond "No info but try again later." } else { set currCond $current }
   set wdir [join [::Visualcrossing::deg_to_dir [dict get $current wdir]]]
   set wspd [dict get $current wspd]
   if {$wdir eq "null" || $wdir eq "" || $wdir eq " "} { set windir "No info but try again later." } else { set windir $wdir }
   if {$wspd eq "null" || $wspd eq "" || $wspd eq " "} { set wspeed "None" } else { set wspeed [expr round($wspd)]km/h}
   if {$wspd ne "null"} {set wspd [expr round($wspd)]}
   set wgust [dict get $current wgust]
   if {$wgust eq "null" || $wgust eq "" || $wgust eq " "} { set wgustmsg "None" } else { set wgustmsg [expr round($wgust)]km/h}
   if {$wgust ne "null"} {set wgust [expr round($wgust)]}
   set temp [dict get $current temp]
   set temp [expr round($temp)]
   
   ### The Third Stack
   set values [dict get $citydata values]
   
   set alert [dict get [lindex $values 0] alerts]
   if {$alert eq "null"} { set alertmsg "No" } else { set alertmsg $alert }
   set mint [dict get [lindex $values 1] mint]
   set mint [expr round($mint)]
   set maxt [dict get [lindex $values 1] maxt]
   set maxt [expr round($maxt)]
   set humi [dict get [lindex $values 0] humidity]
   set humi [expr round($humi)]
   set cond [dict get [lindex $values 0] conditions]
   set cloud [dict get [lindex $values 0] cloudcover]
   set pop [dict get [lindex $values 0] pop]
   set pop [expr round($pop)]

   ### The Fourth Stack
   set sun_moon_data [::Visualcrossing::download_weather https://api.ipgeolocation.io/astronomy?[http::formatQuery apiKey $::Visualcrossing::apiKey location $arg]]
   if {$sun_moon_data == 0} { return }
   set sunmoon_dict [::json::json2dict $sun_moon_data]
   
   set sunrise [dict get $sunmoon_dict sunrise]
   set sunset [dict get $sunmoon_dict sunset]
   set current_time [string range [dict get $sunmoon_dict current_time] 0 4]
   if {$current_time > $sunset} { set currtime "Night" } { set currtime "Day" }
   if {$cloud < 10} {
      if {$currtime eq "Day"} { set sky "Sunny" } else { set sky "Clear" }
   } elseif {$cloud < 20} {
      if {$currtime eq "Day"} { set sky "Sunny to Mostly Sunny" } else { set sky "Fair" }
   } elseif {$cloud < 30} {
      if {$currtime eq "Day"} { set sky "Mostly Sunny" } else { set sky "Mostly Fair" }
   } elseif {$cloud < 60} {
      if {$currtime eq "Day"} { set sky "\u26c5 Partly Sunny" } else { set sky "Partly Cloudy" }
   } elseif {$cloud < 90} { set sky "Mostly Cloudy" } else { set sky "Cloudy" }
         #putlog "Day\Night -> $currtime | CloudCover% -> $cloud | Conditions -> $cond | Sunset time: $sunset and Current time is $current_time ?"

   ### The Fifth Stack
   set weather_data [::Visualcrossing::download_weather https://api.openweathermap.org/data/2.5/weather?[http::formatQuery q $arg appid $::Visualcrossing::appid lang us units metric]]
   if {$weather_data == 0} { return }
   set weather_dict [::json::json2dict $weather_data]
   
   set city [dict get $weather_dict name]
   set country [join [dict get $weather_dict sys country]]
   
   putserv "PRIVMSG $chan :\00307\002$city, $country\003\002 \00314at the moment: \00307$temp°C \00307$cond\003\ \00314Sky\003 \00307$sky\003 \00314Percip Prob \00307$pop\%\003 \00314Humidity \00307$humi\%\003 \00314Wind\003 \00307$wspeed \00314from \00307$wdir\003 \00314Wind gusts\003 \00307$wgustmsg\003 \00314Tomorrow: Min/Max (\003\00307↓$mint\°C\003\00314/\00307↑$maxt\C°\003\00314)\003"
   putserv "PRIVMSG $chan :\00314Alerts:\003 \00304$alertmsg\003"
   if {$alertmsg eq "No"} { return 0 }   
   set alerts [dict get $citydata alerts]
   if {$alerts eq "null"} { return 0 }
   set head [dict get [lindex $alerts 0] headline]
   set onsetEpoch [dict get [lindex $alerts 0] onsetEpoch]
   set endsEpoch [dict get [lindex $alerts 0] endsEpoch]
   set ondate [clock format $onsetEpoch -format "%a, %e %b %Y %H:%M"]
   set offdate [clock format $endsEpoch -format "%a, %e %b %Y %H:%M"]
   
   putserv "PRIVMSG $chan :\[\00304!\003\00314Danger\00304!\003]\ \00304$head \003\[\00314From:\003]\00304 $ondate \003\[\00314To:\003]\00304 $offdate\003"
}
   ### The Second proc for the group cities by ID
proc ::Visualcrossing::group_weather {nick uhost hand chan arg} {
   set group_data [::Visualcrossing::download_weather https://api.openweathermap.org/data/2.5/group?[http::formatQuery id 727447,726051,727011,2643743,7839805 appid $::Visualcrossing::appid lang us units metric]]
   if {$group_data == 0} { return }
   set group_dict [::json::json2dict $group_data]
   
   set cities [dict get $group_dict list]
   set cities_info ""
   foreach city $cities {
      set temp [dict get $city main temp]
      set temp [expr round($temp)]
      if {$temp >=0} {
         set temp "$temp"
         }
      set name [dict get $city name]
      set des [dict get [lindex [dict get $city weather] 0] description]
      lappend cities_info "\00307$name \00304$temp°C\003 /\00314$des\003/"
   }
      putserv "PRIVMSG $chan :\00314Current weather:\003 [join $cities_info " "]"
}
   ### The Third proc for the group Top Largest Cities in the world by IDs
proc ::Visualcrossing::world_weather {nick uhost hand chan arg} {
   set group_data [::Visualcrossing::download_weather https://api.openweathermap.org/data/2.5/group?[http::formatQuery id 1850147,1642911,1273294,1816670,3451190,1701668,1835847,5128638,3530597,360630,524894,2013159,745044,3435907,4887398,264371 appid $::Visualcrossing::appid lang en units metric]]
   if {$group_data == 0} { return }
   set group_dict [::json::json2dict $group_data]
   
   set world_cities [dict get $group_dict list]
   set world_cities_info ""
   foreach world_city $world_cities {
      set world_temp [dict get $world_city main temp]
      set world_temp [expr round($world_temp)]
      set wname [dict get $world_city name]
      set wdes [dict get [lindex [dict get $world_city weather] 0] description]
      lappend world_cities_info "\00307$wname \00304$world_temp°C\003 \00314($wdes)\003"
   }
      putserv "PRIVMSG $chan :\00314World Weather:\003 [join [lrange $world_cities_info 0 7] " "]"      
      putserv "PRIVMSG $chan :[join [lrange $world_cities_info 8 15] " "]"

}
   ### Calculates the degrees from the API and converts them to words expresion like the string below
   ### Attached to the Second Stack of the Main proc
proc ::Visualcrossing::deg_to_dir {value} {
          if {$value eq "null"} { return }
   set calc [expr ($value / 22.5) + 0.5]
   set dirs "North North-Northeast Northeast East-Northeast East East-Southeast Southeast South-Southeast South South-Southwest Southwest West-Southwest West West-Northwest Northwest North-Northeast"
   return [lindex $dirs [expr int($calc) % 16]]
}
   ### Sets the crontab expresion like the string below
proc ::Visualcrossing::auto_say {min hour day month week} {
   ::Visualcrossing::group_weather "-" "-" "-" "#Forbidden" "-"
}
   ### Timer for making the weather posted in a channel, depends on the preference (refer to https://crontab.guru/)
   bind cron -|- "0 */6 * * *" ::Visualcrossing::auto_say
   
   ### The Third Proc for 3 days Forecast
proc ::Visualcrossing::forecast_weather {nick uhost hand chan arg} {
   set forecast_data [::Visualcrossing::download_weather https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$arg/next3days?unitGroup=metric&key=$::Visualcrossing::key]   
   if {$arg == ""} { putserv "PRIVMSG $chan :Syntax: !3 city/location" ; return }
   
   set forecast_dict [::json::json2dict $forecast_data]
   set days_dict [dict get $forecast_dict days]
   
   set address [dict get $forecast_dict address]
   set raddress [encoding convertfrom utf-8 [dict get $forecast_dict resolvedAddress]]   
   set three_list {}
   foreach day $days_dict {
   set temp [dict get $day temp]
   set temp [expr round($temp)]
   set feelslike [dict get $day feelslike]
   set feelslike [expr round($feelslike)]
   set tempmin [dict get $day tempmin]
   set tempmin [expr round($tempmin)]
   set tempmax [dict get $day tempmax]
   set tempmax [expr round($tempmax)]
   set desc [dict get $day description]
   set precipprob [dict get $day precipprob]
   set precipprob [expr round($precipprob)]
      lappend three_list "\002\00307[clock format [dict get $day datetimeEpoch] -format "%a, %e %b"]\002\003 - \00314$desc\003 \00314Temp\003: \00307$temp°C\003 \00314Feels like\003: \00307$feelslike°C\003 \00314Min/Max\003: \00307($tempmin°C/$tempmax°C)\003 \00314Percip\003: \00307$precipprob\%\003"

   }
   putserv "PRIVMSG $chan :\00314Three day forecast for \00307$raddress ($address)\003"
   set three_list [lreplace $three_list 0 0]
   foreach t $three_list {
      putserv "PRIVMSG $chan :$t"
   }
  }
}   

namespace eval SunMoon {
   ### Requirements
   package require json
   package require http
   package require tls
   
   ### Binding
   bind PUB - !a ::SunMoon::pub_sun_moon

   ### The API Keys
   #OpenWeather @ https://openweathermap.org/
   set appid "99ebeb16d27882cdd6df6fc944613f80"
   #IpGeoLocation @ https://ipgeolocation.io/signup.html
   set apiKey "6b0587f490ee4c6786f9b24973826c5a"
   #Visualcrossing @ https://visualcrossing.com/sign-up
   set key "77XX9MDETQ5GHHAHEPFK8W2S4"
   
   ### The Main Astro Proc
proc ::SunMoon::download_data {url} {
   
   ::http::register https 443 [list ::tls::socket -tls1 1]
   ::http::config -useragent "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
   set sun_moon [http::geturl $url -timeout 5000]
   set sun_moon_data [http::data $sun_moon]
   if {[http::status $sun_moon] ne "ok" || [http::ncode $sun_moon] != 200} {
      
   set code [http::code $sun_moon]
   putlog "\00304***\003 SunMoon HTTP error: $code"
   putlog "\00304***\003 Requested url is: $url"
   http::cleanup $sun_moon
   return 0
   }
   http::cleanup $sun_moon 
   return $sun_moon_data
}
proc ::SunMoon::pub_sun_moon {nick uhost hand chan arg} {
   if {$arg == ""} { putserv "PRIVMSG $chan :Syntax: !a city/location" ; return }
   
   set sun_moon_data [::SunMoon::download_data https://api.ipgeolocation.io/astronomy?[http::formatQuery apiKey $::SunMoon::apiKey location $arg]]
   if {$sun_moon_data == 0} { return }
   set sunmoon_dict [::json::json2dict $sun_moon_data]
   
   set current_time [string range [dict get $sunmoon_dict current_time] 0 4]   
   set sunrise [dict get $sunmoon_dict sunrise]
   set sunset [dict get $sunmoon_dict sunset]
   set daylength [dict get $sunmoon_dict day_length]
   set moonrise [dict get $sunmoon_dict moonrise]
   set moonset [dict get $sunmoon_dict moonset]
   set moon_status [dict get $sunmoon_dict moon_status]
   if {$current_time > $sunset} { set currtime "Night" } { set currtime "Day" }
   
   set items_data [::SunMoon::download_data https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/weatherdata/forecast?[::http::formatQuery location $arg aggregateHours 24 forecastDays 3 includeAstronomy true locationMode lookup unitGroup metric shortColumnNames false contentType json alertLevel event lang en nonulls true key $::SunMoon::key]]
   
   ### The Main Astro Dict
   set connect   [::json::json2dict $items_data]
   
   ###The First Astro Stack
   set locations [dict get $connect locations]
   set cityname [lindex $locations 0]
   set citydata [lindex $locations 1]
   set tz [dict get $citydata tz]

   ## The Second Astro Stack
   set current [dict get $citydata currentConditions]
   set moon [dict get $current moonphase]
   if {$moon eq 0 || $moon eq 1} {  set phase "New Moon"
}    elseif {$moon < 0.25} {  set phase "Waxing Crescent"
}    elseif {$moon eq 0.25} {  set phase "First Quarter"
}    elseif {$moon < 0.5} {  set phase "Waxing Gibbous"
}    elseif {$moon eq 0.5} {  set phase "Full Moon"
}    elseif {$moon < 0.75} {  set phase "Waning Gibbous"
}    elseif {$moon eq 0.75} {  set phase "Last Quarter"
}    elseif {$moon < 1} {  set phase "Waning Crescent"
}    else {  set phase "Error. Unknown."   }

   ### The Third Astro Stack
   set values [dict get $citydata values]
   set uv [dict get [lindex $values 0] uvindex]
   if {$uv eq 0 || $uv eq 1 || $uv eq 2 || $uv eq 3 || $uv eq 4}  {   set index "Low"
}   elseif {$uv<5 || $uv eq 6}  {   set index "Medium"
}   elseif {$uv<7 || $uv eq 8}  {   set index "High"
}   elseif {$uv<9 || $uv eq 10} {   set index "Very High"
}   elseif {$uv>11} {   set index "Extreme"
}   else {   set index "Error. Unknown"   }
   set radiation [dict get [lindex $values 0] solarradiation]
   set energy [dict get [lindex $values 0] solarenergy]
   
   ### The Fourth Astro Stack
   set weather_data [::SunMoon::download_data https://api.openweathermap.org/data/2.5/weather?[http::formatQuery q $arg appid $::SunMoon::appid lang us units metric]]
   if {$weather_data == 0} { return }
   set weather_dict [::json::json2dict $weather_data]
   
   set city [dict get $weather_dict name]
   set country [join [dict get $weather_dict sys country]]
   putserv "PRIVMSG $chan :\00314The time in \00306\002$city, $country\003\002 \00314is \00306$current_time\h.\003 \00314Time Zone\003 \00306$tz ($currtime) \003\00314Day length\003 \00304$daylength\h"
   putserv "PRIVMSG $chan :\00314The Sun: \00306Sunrise\003 \00314at \00304$sunrise\h\003 \00314and\003 \00306Sunset \00314at \00304$sunset\h\003 \00306UV index \00304$index\003 ☀️ \00314Radiation \00304$radiation\W/m2\003 ☀️\u26a1 \00314Energy \00304$energy\kWh/m2\003"   
   putserv "PRIVMSG $chan :\00314The Moon: \00306Moonrise\003 \00314at \00304$moonrise\h\003 \00314and\003 \00306Sunset \00314at \00304$moonset\h\00306 Moon Phase \00304$phase\003"   
   }
}
   ### Lastly, help section on NOTICE for a bit more information
   ### Binding
   bind pub -|- !weather pub:help

proc pub:help {nick uhost hand chan text} {
   global botnick
   if {[llength $text]<1} {
   putserv "NOTICE $nick :!w city/location - Shows current weather conditions."
   putserv "NOTICE $nick :!a city/location - Shows astronomy information"
   putserv "NOTICE $nick :!g Shows info for cities IDs as a group from API endpoint."
        putserv "NOTICE $nick :!ww Shows the weather for the largest cities in the world"
   putserv "NOTICE $nick :!3 city/location - Three days forecast."
   
   }
}


putlog "The complete Weather Tcl ...Loaded"