require './wait_times'
require './segment'

##to_school_premium
#wt1 = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
#                   bus_num_1st: '801', dir_1st: Constants::INBOUND, pick_up_1st: '4029', drop_off_1st: '4046',
#                   bus_num_2nd: '331', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '5674', drop_off_2nd: '3360'
#                  )
#puts "From SOCO (StopID 4029) to Ann Richards School (StopID 3360) using premium/rapid"
#wt1.call
#
##from_school_premium
#wt2 = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
#                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
#                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
#                  )
#puts "From Ann Richards School (StopID 2374) to SOCO (StopID 4026) using premium/rapid"
#wt2.call

#to_school_local
seg1 = Segment.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                   bus_number: '1',
                   bus_dir: Constants::OUTBOUND,
                   pick_up_id: '4029',
                   drop_off_id: '524'
                  )
seg1.set_up_bus_hash

seg2 = Segment.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                   bus_number: '331',
                   bus_dir: Constants::OUTBOUND,
                   pick_up_id: '5674',
                   drop_off_id: '3360'
                  )
seg2.set_up_bus_hash

wt3 = WaitTimes.new(segments_array: [seg1, seg2], want_benchmark: true)
puts wt3.generate_json
