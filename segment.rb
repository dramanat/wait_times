require './wait_times'

class Segment
  include Constants

  attr_reader :service_type, :bus_num, :dir, :pick_up_stop_id, :drop_off_stop_id, :bus_hash

  def initialize(svc_type:, bus_number:, bus_dir:, pick_up_id:, drop_off_id:)
    @service_type     = svc_type
    @bus_num          = bus_number
    @dir              = bus_dir
    @pick_up_stop_id  = pick_up_id
    @drop_off_stop_id = drop_off_id
    @bus_hash         = {}
  end

  def set_up_bus_hash
    create_bus_hash
    populate_bus_hash
  end

  def create_bus_hash
    invalid_input = true
    trips_file = File.new('trips.txt')

    trips_file.each {|line|
      if line.start_with?("#{bus_num},#{service_type},")
        bus_info = line.split(',')
        line_trip_id = bus_info[2]
        line_dir_id  = bus_info[5]
        if line_dir_id == dir
          invalid_input = false
          bus_hash[line_trip_id] = {}
        end
      end
    }

    fail "invalid input" if invalid_input
  end

  def populate_bus_hash
    invalid_pick_up_id  = true
    invalid_drop_off_id = true
    stop_times_file = File.new('stop_times.txt')

    stop_times_file.each do |line|
      stop_info      = line.split(',')
      line_trip_id   = stop_info[0]
      line_stop_time = stop_info[1]
      line_stop_id   = stop_info[3]

      if _line_we_seek?(trip_id: line_trip_id, stop_id: line_stop_id)

        utc_stop_time = _create_utc_stop_time(line_stop_time)

        if line_stop_id == pick_up_stop_id
          invalid_pick_up_id  = false
          bus_hash[line_trip_id][pick_up_stop_id]  = utc_stop_time
        end

        if line_stop_id == drop_off_stop_id
          invalid_drop_off_id = false
          bus_hash[line_trip_id][drop_off_stop_id] = utc_stop_time
        end

      end
    end

    fail "invalid pick up stop id"  if invalid_pick_up_id
    fail "invalid drop off stop id" if invalid_drop_off_id
  end

  private
  def _create_utc_stop_time(stop_time)
    stop_time = stop_time.split(':')
    if stop_time[0].to_i >= 24
      tomorrow = Time.now + (24 * 60 * 60 )
      utc_stop_time = Time.utc(tomorrow.year, tomorrow.month, tomorrow.day, (stop_time[0].to_i - 24).to_s, stop_time[1])
    else
      utc_stop_time = Time.utc(YEAR, MONTH, DAY, stop_time[0], stop_time[1])
    end
    utc_stop_time
  end

  def _line_we_seek?(trip_id:, stop_id:)
    bus_hash.key?(trip_id) && [pick_up_stop_id, drop_off_stop_id].include?(stop_id)
  end

end

