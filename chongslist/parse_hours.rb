# yelp hours parser
# mon = 0, tue = 1, wed = 2 ... sun = 6

require 'time'
require 'pp'

def exitProb
  puts 'error'
  exit
end

def getDayOfWeek(day)
  i = case day
    when 'Mon' then 0
    when 'Tue' then 1
    when 'Wed' then 2
    when 'Thu' then 3
    when 'Fri' then 4
    when 'Sat' then 5
    when 'Sun' then 6
    else nil 
  end
  exitProb if i.nil?
  return i
end

def setDays(str)
  days_active = []
  while (str[0..0].downcase <= 'z' && str[0..0].downcase >= 'a')
    day_of_week = getDayOfWeek(str[0..2])
    days_active << day_of_week
    str.slice!(0..2)

    case str[0..1]
      when /-./   #when range
        str.slice!(0..0)
        range_end = getDayOfWeek(str[0..2])
        (day_of_week+1).upto(range_end) do |x|
          days_active << x
        end
        str.slice!(0..3)
      when /\.,/  #when multiple days
        str.slice!(0..1)
      when /\../  #when only day
        str.slice!(0..0)
      else
        exitProb 
    end
  end
  
  return str, days_active  
end

def setHours(str, days_active, week)
  times = str.split('-') 
  exitProb if times.length != 2

  times.each do |time|
    t = Time.parse(time)
    days_active.each do |i|
      week[i] << t.strftime("%H%M%S") 
    end
  end
end

File.open('output', 'r').each do |line| #each restaruant

#line = 'Mon.,Wed-Sun.7:30a.m.-3:00p.m.'
#line = 'Mon-Sun.\t\t\t\t5:30 p.m. - 10:00 p.m.'
#line = 'Mon.11:00a.m.-4:30p.m.'
#line = 'Mon.11:00a.m.-4:30p.m.\n\n\nTue-Thu.11:00a.m.-8:00p.m.\n\n\nFri.11:00a.m.-10:00p.m.\n\n\nSat.10:00a.m.-10:00p.m.\n\n\nSun.10:00a.m.-8:00p.m.'
#line = 'Mon-Thu.\t\t\t\t11:30 a.m. - 3:30 p.m.\n\t\t\t\n\t\t\t\nMon-Thu.\t\t\t\t5:00 p.m. - 10:00 p.m.\n\t\t\t\n\t\t\t\nFri-Sat.\t\t\t\t11:30 a.m. - 3:30 p.m.\n\t\t\t\n\t\t\t\nFri-Sat.\t\t\t\t5:00 p.m. - 10:30 p.m.\n\t\t\t\n\t\t\t\nSun.\t\t\t\t11:30 a.m. - 3:30 p.m.'

  #clear variables for new hours
  mon = []
  tue = []
  wed = []
  thu = []
  fri = []
  sat = [] 
  sun = []
  week = [mon, tue, wed, thu, fri, sat, sun]
  days_active = []

  #break apart hours into lines
  hours_arr = line.gsub(/[\s]/,'').gsub(/\\t/,'').split(/\\n/)
  hours_arr.delete('')
  
  #for each hours line
  hours_arr.each do |str|
    str, days_active = setDays(str)
    setHours(str, days_active, week)

  end 
#puts line.gsub(/[\s]/,'').gsub(/\\t/,'')
puts line
pp week
puts "---------------------------"

end


