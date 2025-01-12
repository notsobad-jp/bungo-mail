class CalendarsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]

  def show
    user = User.find(params[:id])
    events = user.subscribing_campaigns.map(&:to_ics_event)
    ical_data = Calendar.new(events).to_ical

    respond_to do |format|
      format.ics do
        send_data ical_data, filename: "bungomail.ics", type: "text/calendar"
      end
    end
  end
end
