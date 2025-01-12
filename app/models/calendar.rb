class Calendar
  def initialize
    @cal = Icalendar::Calendar.new
    @cal.x_wr_timezone = "Asia/Tokyo"
    @cal.x_wr_calname = "ブンゴウメール"
    @cal.timezone do |t|
      t.tzid = "Asia/Tokyo"
      t.standard do |s|
        s.tzoffsetfrom = "+0900"
        s.tzoffsetto = "+0900"
        s.tzname = "JST"
        s.dtstart = "19700101T000000"
      end
    end
  end

  def add_events(events)
    events.each do |event|
      @cal.add_event(event)
    end
    @cal
  end
end