class Calendar < Icalendar::Calendar
  def initialize
    super
    self.x_wr_timezone = "Asia/Tokyo"
    self.x_wr_calname = "ブンゴウメール配信予定"
    self.timezone do |t|
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
      self.add_event(event)
    end
    self
  end
end