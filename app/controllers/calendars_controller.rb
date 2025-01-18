class CalendarsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]

  def show
    user = User.find(params[:id])
    events = Campaign.created_or_subscribed_by(user).map(&:to_ics_event)
    calendar = Calendar.new.add_events(events).publish

    respond_to do |format|
      format.ics do
        send_data calendar.to_ical, filename: "bungomail.ics", type: "text/calendar"
      end
    end
  end
end
