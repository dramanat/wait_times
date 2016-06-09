require './wait_times'

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
wt3 = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                   bus_num_1st: '1', dir_1st: Constants::OUTBOUND, pick_up_1st: '4029', drop_off_1st: '524',
                   bus_num_2nd: '331', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '5674', drop_off_2nd: '3360'
                  )
puts "From SOCO (StopID 4029) to Ann Richards School (StopID 3360) using local only"
wt3.call
