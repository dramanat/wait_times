require 'pry'
require 'benchmark'

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

  attr_reader :segments, :results, :benchmark_required

  def initialize(segments_array:, want_benchmark:)
    @segments                    = segments_array
    @results                     = []
    @benchmark_required          = want_benchmark
  end

  def find_and_print
    if _valid_input?
      if benchmark_required
        Benchmark.bm(15) do |bench|
          bench.report('benchmark:') do
            _find_wait_times
          end
        end
      else
        _find_wait_times
      end
      puts _create_heading
      _print_results
    end
  end

  private

  def _find_wait_times
    segments[0].drop_off_times.each_index do |drop_off_idx|
      binary_search(drop_off_idx)
    end
  end

  def binary_search(drop_off_idx)
    drop_off_time = segments[0].drop_off_times[drop_off_idx]
    low_index     = 0
    high_index    = segments[1].pick_up_times.length - 1

    while (low_index <= high_index)

      middle_index = (high_index + low_index) / 2
      minute_diff  = _minute_difference(start_time: segments[1].pick_up_times[middle_index],
                                       end_time: drop_off_time)

      if _within_desired_wait_time?(minute_diff)
        #match found!
        _add_to_results(min_diff: minute_diff, drop_off_idx: drop_off_idx, pick_up_idx: middle_index)
        low_index = high_index + 1
      elsif segments[1].pick_up_times[middle_index] < drop_off_time
        #process right side
        low_index = middle_index + 1
      else #segments[1].pick_up_times[middle_index] > drop_off_time
        #process left side
        high_index = middle_index - 1
      end

    end
  end

  def _add_to_results(min_diff:, drop_off_idx:, pick_up_idx:)
    formatted_min_diff = min_diff.to_i.to_s.rjust(2, ' ')
    bus_1_times        = _print_times(seg_idx: 0, times_idx: drop_off_idx)
    bus_2_times        = _print_times(seg_idx: 1, times_idx: pick_up_idx)
    results << "#{formatted_min_diff} min wait : #{bus_1_times} then #{bus_2_times}"
  end

  def _print_results
    results.each {|result|
      puts result
    }
  end

  def _valid_input?
    fail "invalid number of segments" if segments.length != 2

    if segments[0].service_type != segments[1].service_type
      fail "segments need to have same service type"
    end

    if segments[0].bus_num == segments[1].bus_num
      fail "segments should have different bus numbers"
    end

    true
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

  def _print_times(seg_idx:, times_idx:)
    times_str = _extract_time(segments[seg_idx].pick_up_times[times_idx])
    times_str << " -> "
    times_str << _extract_time(segments[seg_idx].drop_off_times[times_idx])
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
