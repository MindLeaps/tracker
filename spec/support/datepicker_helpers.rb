module Helpers
  def select_datepicker_date(field_id, date)
    date = date.to_date
    field = find("##{field_id}")
    displayed_date = field.value.present? ? Date.iso8601(field.value) : Date.current
    field.click
    calendar = datepicker_calendar_for(field)
    navigate_datepicker(calendar, displayed_date, date)
    choose_datepicker_date(calendar, date)
  end

  private

  def datepicker_calendar_for(field)
    datepickers = all('[data-controller="datepicker"]')
    field_wrapper = field.find(:xpath, '..')
    field_index = datepickers.index { |datepicker| datepicker.path == field_wrapper.path }
    calendars = all('.pika-single', visible: :all)
    calendars[calendars.length - datepickers.length + field_index]
  end

  def navigate_datepicker(calendar, displayed_date, date)
    month_delta = ((date.year * 12) + date.month) - ((displayed_date.year * 12) + displayed_date.month)
    direction = month_delta.positive? ? 'next' : 'prev'
    month_delta.abs.times do
      within calendar do
        find("button.pika-#{direction}").click
      end
    end
  end

  def choose_datepicker_date(calendar, date)
    within calendar do
      find("button.pika-day[data-pika-year='#{date.year}'][data-pika-month='#{date.month - 1}'][data-pika-day='#{date.day}']").click
    end
  end
end
