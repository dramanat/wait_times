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

  attr_reader :service_type,
    :first_bus_number, :first_bus_dir, :first_bus_pick_up_stop_id, :first_bus_drop_off_stop_id,
    :second_bus_number, :second_bus_dir, :second_bus_pick_up_stop_id, :second_bus_drop_off_stop_id

  def initialize(svc_type:,
                 bus_num_1st:, dir_1st:, pick_up_1st:, drop_off_1st:,
                 bus_num_2nd:, dir_2nd:, pick_up_2nd:, drop_off_2nd:
                )
    @service_type                = svc_type
    @first_bus_number            = bus_num_1st
    @first_bus_dir               = dir_1st
    @first_bus_pick_up_stop_id   = pick_up_1st
    @first_bus_drop_off_stop_id  = drop_off_1st
    @second_bus_number           = bus_num_2nd
    @second_bus_dir              = dir_2nd
    @second_bus_pick_up_stop_id  = pick_up_2nd
    @second_bus_drop_off_stop_id = drop_off_2nd
  end

  def call
    first_bus = create_bus_hash(first_bus_number, service_type, first_bus_dir)
    populate_bus_hash(first_bus_pick_up_stop_id, first_bus_drop_off_stop_id, first_bus)

    second_bus = create_bus_hash(second_bus_number, service_type, second_bus_dir)
    populate_bus_hash(second_bus_pick_up_stop_id, second_bus_drop_off_stop_id, second_bus)

    puts _create_heading
    find_wait_times(first_bus, first_bus_drop_off_stop_id, second_bus, second_bus_pick_up_stop_id)
  end

  def create_bus_hash(route_id, service_id, direction_id)
    invalid_input = true
    bus_hash = {}
    trips_file = File.new('trips.txt')

    trips_file.each {|line|
      if line.start_with?("#{route_id},#{service_id},")
        bus_info = line.split(',')
        line_trip_id = bus_info[2]
        line_dir_id  = bus_info[5]
        if line_dir_id == direction_id
          invalid_input = false
          bus_hash[line_trip_id] = {}
        end
      end
    }

    fail "invalid input" if invalid_input
    bus_hash
  end

  def populate_bus_hash(pick_up_id, drop_off_id, bus_hash)
    invalid_pick_up_id  = true
    invalid_drop_off_id = true
    stop_times_file = File.new('stop_times.txt')

    stop_times_file.each {|line|
      stop_info      = line.split(',')
      line_trip_id   = stop_info[0]
      line_stop_time = stop_info[1]
      line_stop_id   = stop_info[3]

      if _line_we_seek?(
          bus_hash: bus_hash,
          trip_id: line_trip_id,
          stop_id: line_stop_id,
          pick_up_id: pick_up_id,
          drop_off_id: drop_off_id)

        utc_stop_time = _create_utc_stop_time(line_stop_time)

        if line_stop_id == pick_up_id
          invalid_pick_up_id  = false
          bus_hash[line_trip_id][pick_up_id]  = utc_stop_time
        end

        if line_stop_id == drop_off_id
          invalid_drop_off_id = false
          bus_hash[line_trip_id][drop_off_id] = utc_stop_time
        end

      end
    }

    fail "invalid pick up stop id"  if invalid_pick_up_id
    fail "invalid drop off stop id" if invalid_drop_off_id
    nil
  end

  def find_wait_times(first_bus, drop_off, second_bus, pick_up)
    first_bus.each {|bus_1_key, bus_1|
      second_bus.each {|bus_2_key, bus_2|
        next if bus_2[pick_up] < bus_1[drop_off]
        minute_diff = _minute_difference(bus2_pick_up: bus_2[pick_up], bus1_drop_off: bus_1[drop_off])
        if _within_desired_wait_time?(minute_diff)
          puts "#{minute_diff.to_i.to_s.rjust(2, ' ')} min wait : #{_print_times(bus_1)} then #{_print_times(bus_2)}"
          break
        end
      }
    }
  end


  def _create_utc_stop_time(stop_time)
    stop_time = stop_time.split(':')
    if stop_time[0].to_i >= 24
      utc_stop_time = Time.utc(YEAR, MONTH, DAY + 1, (stop_time[0].to_i - 24).to_s, stop_time[1])
    else
      utc_stop_time = Time.utc(YEAR, MONTH, DAY, stop_time[0], stop_time[1])
    end
    utc_stop_time
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

  def _line_we_seek?(bus_hash:, trip_id:, stop_id:, pick_up_id:, drop_off_id:)
    bus_hash.key?(trip_id) && [pick_up_id, drop_off_id].include?(stop_id)
  end

  def _minute_difference(bus2_pick_up:, bus1_drop_off: )
    (bus2_pick_up - bus1_drop_off) / 60
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
    output << first_bus_pick_up_stop_id.rjust(18)
    output << "    -> "
    output << first_bus_drop_off_stop_id.rjust(4)
    output << second_bus_pick_up_stop_id.rjust(14)
    output << "   -> "
    output << second_bus_drop_off_stop_id.rjust(4)
    output
  end

end
