require 'pry'

module Constants
  WEEKDAY_SERVICE_ID  = '1'
  SATURDAY_SERVICE_ID = '4'
  SUNDAY_SERVICE_ID   = '5'
  OUTBOUND = '0'
  INBOUND  = '1'
  MIN_WAIT_TIME = 5
  MAX_WAIT_TIME = 15
  YEAR  = Time.now.year
  MONTH = Time.now.month
  DAY   = Time.now.day
end


class WaitTimes
  include Constants

  attr_reader :segments, :results

  def initialize(segments_array:)
    @segments                    = segments_array
    @results                     = []
  end

  def call

    fail "invalid number of segments" if segments.length != 2

    find_wait_times
    puts _create_heading
    print_results

  end

  def find_wait_times
    segments[0].bus_hash.each {|bus_1_key, bus_1|
      segments[1].bus_hash.each {|bus_2_key, bus_2|
        next if bus_2[segments[1].pick_up_stop_id] < bus_1[segments[0].drop_off_stop_id]
        minute_diff = _minute_difference(start_time: bus_2[segments[1].pick_up_stop_id],
                                         end_time: bus_1[segments[0].drop_off_stop_id])
        if _within_desired_wait_time?(minute_diff)
          results << "#{minute_diff.to_i.to_s.rjust(2, ' ')} min wait : #{_print_times(bus_1)} then #{_print_times(bus_2)}"
          break
        end
      }
    }
  end

  def print_results
    results.each {|result|
      puts result
    }
  end

  def _extract_time(date_time)
    rjustified_min = date_time.min.to_s.rjust(2, '0')
    hour_in_standard_time = if date_time.hour < 12
                              date_time.hour.to_s.rjust(2, '0')
                            elsif date_time.hour == 12
                              date_time.hour
                            else
                              (date_time.hour - 12).to_s.rjust(2, '0')
                            end
    time_str = "#{hour_in_standard_time}:#{rjustified_min}"
    date_time.hour > 11 ? time_str << "pm" : time_str << "am"
    time_str
  end

  def _minute_difference(start_time:, end_time:)
    (start_time - end_time) / 60
  end

  def _print_times(times_hash)
    fail 'invalid times_hash' if times_hash.length != 2
    times_str = ""
    times_hash.each_with_index{ |(k, v), idx|
      times_str << " -> " if idx == 1
      times_str << _extract_time(v)
    }
    times_str
  end

  def _within_desired_wait_time?(minute_diff)
    minute_diff > MIN_WAIT_TIME && minute_diff < MAX_WAIT_TIME
  end

  def _create_heading
    output = ""
    output << segments[0].pick_up_stop_id.rjust(18)
    output << "    -> "
    output << segments[0].drop_off_stop_id.rjust(4)
    output << segments[1].pick_up_stop_id.rjust(14)
    output << "   -> "
    output << segments[1].drop_off_stop_id.rjust(4)
    output
  end

end
