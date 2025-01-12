class CalendarsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]

  def show
    user = User.find(params[:id])

    respond_to do |format|
      format.ics do
        ical_data = Campaign.to_ics(user.id)
        send_data ical_data, filename: "bungomail.ics", type: "text/calendar"
      end
    end
  end
end
