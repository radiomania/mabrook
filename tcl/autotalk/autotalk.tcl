## -----------------------------------------------------------------------
##           AutoTalk.TCL ver 1.0 Disign by: (-=�razyFire=-)                               
## -----------------------------------------------------------------------
## FOR MORE INFORMATION VISIT OUR CHANNEL (bot home #Djebel) 
## my email : crazy@link.bg
## AutoTalk.TCL V1.0
## by: (-=�razyFire=-)
## 
## All newsheadlines parsed by this script are (C) AutoTalk`eggdrop`team 
## 
## AutoTalk Version History:1 Command    V1.0  - Public command like (botnick) (command) 
##                        2 protection   v1.0  - This script i just made medium protection
##                                              if some one flood color or say bad word or what on channel
##                                              the bot will lock channel for a moment (mode +mi).
##                                              ( i have been tried it on Channel #Djebel)                                       
##                        3 entertainment v1.0 - Auto speak and respon :).
##                                        v1.1 - Auto speak when some one change they nickname
##                                        v1.2 - Auto speak when some get kick or join channel.          
## The author takes no responsibility whatsoever for the usage and working of this script !
## 

## ----------------------------------------------------------------
## Set global variables and specificic
## ----------------------------------------------------------------

## -=[ SPEAK ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "#channel1 #channel2"
set speaks_chans "*"

# Set you want in XXX minute you bot always talk on minute 
set speaks_time 90

## -=[ Hello ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "*"
set hello_chans "*"

## -=[ BRB ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "*"
set brb_chans "*"

## -=[ BYE ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "*"
set bye_chans "*"

## -=[ PING ]=-  Set the next line as the channels you want to run in
## for all channel just type "*" if only for 1 channel or 2 chnnel just
## type "*"
set ping_chans "*"


## ----------------------------------------------------------------
## --- Don't change anything below here if you don't know how ! ---
## ----------------------------------------------------------------

######################################################################
##--------------------------------------------------------------------
##--- F O R     ---   E N T E R T A I N M E N T  ---    CHANNEL   ----
##--------------------------------------------------------------------
######################################################################         
### SPEAK ###
set spoken.v "Auto talk"
# Set the next lines as the random speaks msgs you want to say
set speaks_msg {
  {"Masakit ang maiwan, pero mas masakit ang manatili sa isang relasyong alam mong ikaw na lang ang nagmamahal."}
  {"Kung  respeto ang hinahanap mo, unahin mo munang respetuhin sarili mo."}
  {"Haide, tragvai si, che idat i ne iskam da te vidiat. Vanio, Pesho, Uri, Joro shte mi go nachukat  skoro."}
  {"Minsan nakakatamad na din magseryoso. Lalo na't parati ka nalang niloloko. !!!"}
  {"- Mahal mo kasi maputi? It's not love, it's Dove!. :)))"}
  {"Wag kang magpakatanga sa taong binabalewala ka. :)"}
  {"Pwede ba tayong magkunwaring mahal natin ang isat-isa?? Tapos totohanin na lang natin pag-naniwala na sila. ???"}
  {"Hindi ka bibigyan ng pagsubok ni lord kung alam niyang hindi mo kaya. ???"}
  {"Jivota e bolest koqto se predava po polov pat i se lekuva edinstveno sas smart !!!"}
  {"Bakit ang hirap mag move on sa taong minahal mo ng sobra peru kahit minsan, hindi mo man lang naramdamang minahal ka."}
  {"Ang mag syota daw ay parang presyo ng bagong model na cellphone. Sa una nagmamahalan tapos di magtatagal magmumurahan! :)))"}
  {"!!! Sa panahon ngayon, bihira na yung babaeng kinakasal muna bago mabuntis.!!!"}
  {"Hindi ko naman hinihiling na ako ang unahin mo. Ayoko lang maramdaman na parang wala lang ako sayo."}
  {"Jeep nga umaalis, pag napupuno. Tao pa kaya?"}
  {"- Niligawan ka sa text tapos sinagot mo, asan yung love dun? Nasa simcard?"}
  {"Wag kang masyadong kampanteng mahal ka niya. Kasing lakas man ng alak ang tama niya sayo, baka isusuka ka rin niya."}
  {"Kung respeto ang hinahanap mo, unahin mo munang respetuhin sarili mo...."}
  {"- Kung kayo kayo talanga! Payo ng kaibigang nagsasawa na sa katangahan mo...."}
  {"- Kung tinanong ka ng manliligaw mo kung chocolates o flowers be practical! Bigas men bigas!"}
  {"- Kahit ano pa sa'yo, kahit ano kapa, hindi mahalaga ang sasabihin ng ibo."}
  {"- Minsan kailangan muna nating masaktan bago tayo matauhan."}
  {"- Ang iyong paglisan ay bangungot na sasakal sa hininga ng bawat gabing waiisip kong kalimutan ka pero hindi ko kailanman magagawa."}
  {"- Minsan ang buhay parang yang roller coaster, dadalhin ka sa pinakamasasaya at pinakanakakatakot na parte."}
  {"- Walang salitang Pagod na ako sa magulang na OFW. Basta para sa kinabukasan ng anak, kinakaya, gaano man kahirap."}
  {"Hindi importante ang sobrang dami ng pera. Ang importante may masayang pamilya.!"}
  {"Ang pamilya parang buwan lang yan, hindi mo man minsan nakikita, pero alam mong nandyan lang iyan."}
  {"Mabuti pa yung deadline sa school, kahit anong hirap, hahabulin mo. Samantalang ako, umalis na, lumakad na, nandyan ka pa rin nakatayo."}
  {"- Kakva e razlikata mejdu kurva i ku4ka? - Kurvata go pravi s vsi4ki na kupona, a ku4kata - s vsi4ki na kupona... osven s teb!"}
  {"- Okay lang kung bagsak ka sa kanya, ang mahalaga, sa school pasado ka.!"}
  {"Oo napasagot mo siya, e yung exam mo nasagot mo ba?!"}
  {"Iwan ka man ng mga kaibigan mo. Iwan ka man ng taong minamahal mo, at kahit talikuran ka pa ng mundo, di magbabago ang pagmamahal sayo ng pamilya mo."}
  {"- Buti pa ang pamasahe ng tren tumaas. Sweldo ko na lang ang hindi."}
  {"- Dahil sa sobrang traffic sa EDSA, naniniwala na ako sa forever...."}
  {"Para kang aplikante ko, nangakong darating hindi naman.... "}
  {"-Nabubuhay tayo, hindi para bumitaw at bumigay, kundi para lumaban at matuto."}
  {"Sana yung pagmamahal mo parang hugasin rin sa bahay, hindi nauubos."}
  {"May taong binigay ng Diyos para lang makilala mo at hindi para makasama mo.."}
  {Sa pag-ibig walang bulag, walang pipi, walang bingi, pero tanga madami.:>>>."}
  {"Importante naman talaga ang pinagsamahan, pero mas mahalaga ang pagsasabi ng katotohanan.."}
  {"If Plan A fails, remember there are 25 more letters. :=)))"}
  {"- Life is about balance. Be kind, but don't let people abuse you. Trust, but don't be deceived. Be content, but never stop improving yourself.:)"}
  {"Gusto mo ng magandang tanawin, tumitig ka sa sa akin.!!!"}
  {"Mas okay na yung friendship na parang may something, kaysa sa relationship na parang nothing.!"}
  {"-Magkulang ka na sa iba huwag lang sa pamilya."}
  {"-Wala naman masama pag-magmahal ka ng sobra-sobra basta ba, wag lang sosobra ng ISA.!"}
  {"Paglayuin man tayo ng panahon, wala ka man sa tabi ko ngayon. Alalahanin mong lagi kang nasa puso ko at ikaw ang laging laman ng isip ko.!"}
  {"-Kaya kong panindigan ang salitang IKAW LANG basta wag mo lang akong tratuhing WALA LANG..:-)))"}
  {"Iwasan ang mgpaasa ng tao, dahil baka dumating ang isang araw ang akala mo nandiyan pa sya na umaasa sau, yon pla ikaw na lang ang UMAASA SA KANYA.."}
  {"Yung taong yayakapin ka sa likod, at ididikit ang mga labi sa tenga mo at sasabihin sayo Di kita iiwan. ;-)))"}
  {"LOVE is PATIENT. LOVE is KIND.."}
  {"Ang pagmamahal ay para sa dalawang tao lang, ewan ko ba kung bakit may mga malalanding di marun0ng magbilang..:-))) muhahaha...."}
  {"Minsan may nagtanong sakin kung nainlove na daw ako. Napangiti ako sa sinabi niya Because at that very moment..I was thinking of YOU.."}
  {"Ang tunay na Pag-ibig? Yun yung di mo alam kung baket mo siya nagustuhan pero minahal mo siya sa di mo maipaliwanag na DAHILAN.."}
  {"Kung magkakaroon ako ng sariling planeta, gusto ko ikaw ang aksis nito, para sa iyo lang iikot ang mundo ko.."}
  {"-Minahal kita, Namiss, Kinailangan, Ninais Ngunit ang lahat ng iyan ay nakalipas na kaya huwag nang mag-isip na bumalik pa.."}
  {"Pangalan mo pa lang kinikilig na ako. Paano pa kaya kung magka-apelyido na tayo?.:-)))"}
  {"Stay safe ka ng stay safe..' bakit nung safe ka sakin nagstay ka ba? :-)))"}
  {"Karanasan ang magsilbing aral sa tinatahak mong buhay.:-=)))"}
  {"Matatalino ang mga taong mas maraming pangarap na hindi masisira ng realidad!!.:-=)))"}
  {"May mga bagay na alam mong walang patutungohan pero pinagpapatuloy mo pa rin kasi dun ka masaya.."}
  {"Padumating na yung oras na sinusubok na tayo ng panahon, sana mas piliin natin ang lumaban kaysa sumuko.."}
  {"Sangkatutak na kape para simulan ang araw mo, Sabayan mo ng ngiti, eto ang tamang timpla sa nakakapagod na mundo."}
  {"Kinilig na sana ako eh, Parang kayo, pero hindi. Parang mahal ka, tanga hindi. Friendly ka lang pala.."}
  {"Ang simula at wakas ay magkamukha; sa bawat wakas ay may nakalaang simula......:-=)))"}
  {"Bitawan ang nawala, asahan ang darating, magpasalamat sa kung ano ang mananatili.."}
  {"Mas mahusay na maghintay, kaysa pilitin ang mga bagay na gusto mo agad mangyari.."}
  {"Kung malabo man sa tingin ng iba yung mga bagay na ginagawa mo, wag kang gagawa ng dahilan para sumuko, Hindi uso ang salitang mahirap sa taong pursigido.."}
  {"Huwag kang matakot sumubok, lagi mong tandaan na ang pag-katalo ay silbing aral sa mga karanasan mo at dun ka natututo...."}
  {"Kakvo e blondinka boqdisala si kosata vav 4erno? -Izkustven intelekt."}
  {"-Hindi ako malakas, ngunit may malakas akong Diyos na nagpoprotekta sa akin bawat sandali ng aking buhay."}
  {"Unti-unti ko ng natutunan tanggapin ang mga bagay na dati ayaw kong mawala.!:-=)))"}
  {"Mas ituon ang pansin sa mga taong nagbibigay inspirasyon sa sarili mo, kaysa sa mga taong naninira sayo. Mas Makakakuha ka ng positibong pananaw sa buhay."}
  {"Tandaan palagi na kung wala sayo ang bagay na gusto mo, mas mabuting gustuhin mo ang bagay na mayroon ka, Sa ganito natin mahahanap ang tunay na saya.!."}
  {"Kailan ka ba magigising sa katotohanan na yung taong pinaglalaban mo ay may pinaglalaban ng iba.!"}
  {"In the realm of uncertainty, a warm hug speaks volumes where words fall short..:-=)))"}
  {"When faced with the unknown, remember that a simple hug can bridge the gap between uncertainty and understanding.."}  
  {"When faced with the enigma of life, embrace it with a hug, for its language transcends all puzzles. :->>>."}
  {"When the riddles of existence baffle your mind, let a heartfelt hug be the answer that brings solace..:-=)))"}
  {"Amidst the mysteries that surround us, a hug shines as a beacon of understanding and comfort.."}
  {"When life poses questions without words, a tender embrace holds the key to unspoken answers.."}
  {"The beauty of a hug lies in its ability to unravel the unknown, unraveling the mysteries of the heart.."}
  {"In the face of the unanswered, let the language of hugs convey the unspoken truths of compassion and connection.."}
  {"When the world presents conundrums, seek refuge in the gentle embrace of a hug, for it brings clarity to the unknown...."}
  {"2 + 2 = 5 for extremely large values of 2."}
  {"A hug, the universal response to life's riddles, unlocks the secrets hidden within the questions we dare not ask.."}
  {"- Lagi kong sinasabi sa sarili ko na, Bakit ganito ka lang pagka-masungit? pero di rin naman natututo...."}
  {"Buti pa supervisor hinahanap, ako hindi ang sakit."}
  {"Minsan ka lang nga maakabayan pero holdap pa!."}
  {"-I've never been loved like this before.."}
  {"Kung may gusto kang mahalin, wag ka nalang mag-isip. Iyan lang ang masasabi ko. [*=-"}
  {"-Pero paano mo ba mapapigilan ang pagtitiwala sa sarili mong kalamangan?"}
  {"I know you want someone to love you. But what about loving yourself first?..."}
  {"No matter how much pain is inflicted, I will always have hope...."}
  {"-I can't seem to forget the memories of us together. You're my perfect stranger...."}
  {"If I could choose between loving you and breathing, I would use my last breath to say, I love you..."}
  {"-Puro ikaw at iba pang kulay na lang ang nakalarawan sa puso ko. -="}
  {"You're the only color in my heart. (ano?)."}
  {"-Pag nakikita kang may gusto sa 'yo, buksan mo na muna ang pintuan."}
  {"-If you see someone who wants to be with you, open the door. .."}
  {"Kung wala ka man magagawa ng masasayang bagay para lang sa akin, huwag kang maniniwala na mahal mo rin ako.."}
  {"Kapag pinakilala sa'yo ang taong hindi natin kayang makausap, ikaw pala yung bida...."}
  {"If you ever meet someone you can't talk to, that is probably the person who likes you. (talaga?)."}
  {"- Ikaw ang pinakamagandang kasal sa buhay ko.."}
  {"You are my best wedding so far. ( ha!!?!) ..."}
  {"-Kapag niloko mo na ako, sisirain lang ng buhay mo ang oras ko.."}
  {"When you make fun of me I will destroy the time in my life. ( what?!) .:-)))"}
  {"Gamitin ang puso para alagaan ang taong malapit sayo. Gamitin ang utak para alagaan ang sarili mo...."}
  {"Marami ang nakakakilala sayo Pero konti lang ang tunay na nakakaintindi sayo..."}
  {"Kahit hirap na hirap kana, hindi ka dapat sumuko. Ganun talaga kapag bida, Nagpapatalo sa una!"}
  {"- May mga feelings talaga na hanggang Social Media nalang.."}
  {"- Ikaw na nga yung nasaktan Ikaw pa ang nag so-sorry.."}
  {"-Pinagtagpo kayo ng tadhana pero di kayo ang itinakda.."}
  {"Bundok. Minsan lugar. Madalas trabaho..."}
  {"Ultimate office automation: networked coffee."} 
  {"RAM disk is *not* an installation procedure."}
  {"Shell to DOS... Come in DOS, do you copy? Shell to DOS..."}
  {"Wala akong pinapatamaan. Assuming ka lang talaga....:-)))"}
  {"Ang karma parang pelikula. Kung hindi showing malamang coming soon.."}
  {"Relationship status: COMMITTED sa work.."}
  {"Papel. Minsan office supply. Madalas ikaw!!..."}
  {"Dalawa lang ang kailangan. Marunong makuntento at may matinong trabaho.!!"}
  {"Forest ako. Punong-puno na sa'yo!.:)))"}
  {"Isang bucket para sa lahat ng baket."}
  {"Congrats. Wala kang ginawa maghapon.!"}
  {"Manahimik ka dahil hindi kita nilalait. Dini-describe kita.."}
  {"Para kang sunrise. PASIKAT."}
  {"Ang luha ay parang pawis. Di man parehong galing sa mata, pero parehong tumutulo pag pagod ka na.!"}
  {"Kung napapako din lang naman lahat ng pangako mo. Edi sana nagkarpentero ka na lang."}
  {"Press any key... no, no, no, NOT THAT ONE!"}
  {"Press any key to continue or any other key to quit..."}
  {"Ako leviat ti krak beshe Koleda, a desnia Nova godina, bih iskal da te posetia mejdu praznicite."}
  {"Minsan kailangan mong namahimik kahit tama ka. Dahil hindi ka mananalo kung tanga ang kausap mo."}
  {"Magpapahula nga ako sa mga tsismosa. Minsan kasi kahit hindi pa nagyayari, alam na nila!.:)))"}
  {"Ang crush nagsisimula sa mata, pumapasok sa dibdib, tumatambay sa isip, nagiging bukambibig, kaya sa huli nagiging pag-ibig.!"}
  {"Ebi navred ebi bezchet ebi baldazi belogazi ebi vseki koito se nagazi ebi i toz koito go chete za da ne moje toi teb da te ebe!!!"}
  {"My toes, may knees, my crush is manhid.."}
  {"Iba ang crush sa mahal. Bakit ka nagseselos?!!!"}
  {"Bawal masaktan, lalo na kung crush pa lang.!!!"}
  {"Ayokong dumating tayo sa point na lalayuan mo ko kasi nalaman mo lang na may gusto ako sa'yo."}
}

if {![string match "*time_speaks*" [timers]]} {
  timer $speaks_time time_speaks
}

proc time_speaks {} {
  global speaks_msg speaks_chans speaks_time
  if {$speaks_chans == "*"} {
    set speaks_temp [channels]
    } else {
    set speaks_temp $speaks_chans
  }
  foreach chan $speaks_temp {
    set speaks_rmsg [lindex $speaks_msg [rand [llength $speaks_msg]]]
    foreach msgline $speaks_rmsg {
      puthelp "PRIVMSG $chan :[subst $msgline]"
    }
  }
  if {![string match "*time_speaks*" [timers]]} {
    timer $speaks_time time_speaks
  }
}



##  PING PONG ##
set Reponden2.v "Ping Respon"
bind pub - "rakia" ping_speak 
bind pub - "rakiq" ping_speak
bind pub - "bira" ping_speak
bind pub - "biri" ping_speak
bind pub - "piem" ping_speak
bind pub - "vodka" ping_speak
bind pub - "vodki" ping_speak
bind pub - "piq" ping_speak

set ranping {
  "Mabilis kang matuto.??? -ha Bagay sa 'yo 'yan.:o)))"
  "Ang ganda ng ngiti mo....  ouuuu...!!! -a Masipag ka at mahusay.:o)))"
  "vodka vodka...  ouuuu...!!! -a Gusto ko 'yang sinabi mo. :o)))"
  "Ipagpatuloy mo lang 'yan." 
  "Da best ka talaga!"
  "Ang sarap mong magluto."
  "Mapagkakatiwalaan ka talaga. :)))"
  "Ang bait mo talaga. - Cute ka."
  "Mukhang maganda 'yan... :)))"
  "Ang sarap mong kasama."
  "Nakakabilib ang tyaga mo."
  "Nakakabilib ka. ;o)"
  "Maganda ka."
  "aee... Pakiabot ng ulam. :)))"
  "Anong gusto mong inumin?"
  "Umorder ka kahit ano. Sagot ko...mmmm"
}

proc ping_speak {nick uhost hand chan text} {
  global botnick ping_chans ranping
  if {(([lsearch -exact [string tolower $ping_chans] [string tolower $chan]] != -1) || ($ping_chans == "*"))} {
    set pings [lindex $ranping [rand [llength $ranping]]]
    putserv "PRIVMSG $chan :$nick $pings"
  }
} 

##  hello ##
set Reponden3.v "hello Respon"
bind pub - "hello" hello_speak 
bind pub - "alo" hello_speak 
bind pub - "zdr" hello_speak 
bind pub - "hai" hello_speak 
bind pub - "hi" hello_speak 

set ranhello {
  "Mabuhay!"
  "Magandang araw ^_^"
  "Magandang umaga"
  "helooooooooo"
  "Kumusta ka naman?"
  "Musta na u?"
  "Anong bago?"
  "Hi there"
  ":) Tagal na nating hindi nagkita!"
  "Ayos lang."  
  "yeah, yeah hi HI"
  "Walang ano man!!!"
  "Ingat!"
  "hi asl pls?"
  "how do you do? i'm happy to meet you"
  "Taga saan ka??"
  "Saan ka pupunta? ?"
  "Saan ito papunta?"
  "Uwi na ako :>>"
  "Paalam ?"
  "Sa uulitin! _!_"
}

proc hello_speak {nick uhost hand chan text} {
  global botnick hello_chans ranhello
  if {(([lsearch -exact [string tolower $hello_chans] [string tolower $chan]] != -1) || ($hello_chans == "*"))} {
    set helos [lindex $ranhello [rand [llength $ranhello]]]
    putserv "PRIVMSG $chan :$nick $helos"
  }
} 

##  Brb  ##
set Reponden4.v "Brb Respon"
bind pub - "brb" brb_speak 
set ranbrb {
  "Magkano ang pamasahe?"
  "Hindi ko alam!?"
  "Pabili po!"
  "Magkano lahat?! ;)"
  "Pwede pong tumawad?"
}

proc brb_speak {nick uhost hand chan text} {
  global botnick brb_chans ranbrb
  if {(([lsearch -exact [string tolower $brb_chans] [string tolower $chan]] != -1) || ($brb_chans == "*"))} {
    set brbs [lindex $ranbrb [rand [llength $ranbrb]]]
    putserv "PRIVMSG $chan :$nick $brbs"
  }
} 

##  Bye  ##
set Reponden5.v "Bye respon"
bind pub - "bye" bye_speak 
bind pub - "4ao" bye_speak 
bind pub - "chao" bye_speak 
set ranbye {
  "Gutom na ako!"
  "oki bye:-):P~~ Gusto ko nang kumain!"
  "oki bye:-):P~~ Masarap!"
  "ok Kain ka pa! :)"
  "good bye.. Busog na ako! :)"
  "Ayaw ko na."
  "Wala na akong gana."
  "Magdasal tayo!"
  "Saan ako pwedeng umupo?:PPP~~~~~"
  "Bahala ka na! ?:)))"
  "Gusto kitang makasama habang buhay.:-)"
  "Walang iba, ikaw lang.:-)))"
  "Andito ako lagi para sa 'yo. sq:P~~"
  "eee Ikaw ang mundo ko. :-)"
  "Binago mo ang buhay ko. :))"
  "Pinagaganda mo ang araw ko."
  "mahai sa ma ufca"
  "In love ako sa 'yo"
  "fiiiiuuuuuu----... Mahal na mahal kita."
}

proc bye_speak {nick uhost hand chan text} {
  global botnick bye_chans ranbye
  if {(([lsearch -exact [string tolower $bye_chans] [string tolower $chan]] != -1) || ($bye_chans == "*"))} {
    set byes [lindex $ranbye [rand [llength $ranbye]]]
    putserv "PRIVMSG $chan : $nick $byes"
  }
} 


## -----------------------------------------------------------------------
#putlog "-=-=   ENTERTAINMENT  PROSES   =-=-=-=-=-"
#putlog "Entertainment Channel (auto/respon) Ver 1.0:"
#putlog "1.${spoken.v},2.${Reponden2.v},3.${Reponden3.v}"
#putlog "4.${Reponden4.v},5.${Reponden5.v}"
putlog "AutoTalk bY dJ_TEDY Loaded. \002[join $speaks_chans ", "]\002"
##------------------------------------------------------------------------
##                      ***    E N D   OF  ENT1.0.TCL ***
## -----------------------------------------------------------------------
