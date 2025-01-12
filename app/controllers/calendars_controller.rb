class CalendarsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]

  def show
    user = User.find(params[:id])
    events = user.subscribing_campaigns.map(&:to_ics_event)
    ical = Calendar.new.add_events(events).publish.to_ical

    respond_to do |format|
      format.ics do
        send_data ical, filename: "bungomail.ics", type: "text/calendar"
      end
    end
  end
end
