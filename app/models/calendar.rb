class Calendar
  def initialize(events)
    @calendar = Icalendar::Calendar.new
    @calendar.x_wr_timezone = "Asia/Tokyo"
    @calendar.x_wr_calname = "ブンゴウメール配信予定"
    @calendar.timezone do |t|
      t.tzid = "Asia/Tokyo"
      t.standard do |s|
        s.tzoffsetfrom = "+0900"
        s.tzoffsetto = "+0900"
        s.tzname = "JST"
        s.dtstart = "19700101T000000"
      end
    end

    events.each do |event|
      @calendar.add_event(event)
    end

    @calendar.publish
  end

  def to_ical
    @calendar.to_ical
  end
end