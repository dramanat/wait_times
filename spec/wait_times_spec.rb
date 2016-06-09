require 'pry'
require './wait_times'
describe "wait_times"do

  context "#_create_utc_stop_time" do

    context "hour is greater than 24" do
      it "increments day and subtracts 24 from hour" do
        wt        = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                  bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                  bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                 )
        stop_time = '25:10'
        utc       = wt._create_utc_stop_time(stop_time)
        utc.day.should eql Constants::DAY + 1
        utc.hour.should eql 1
      end
    end

    context "hour is less than 24" do
      it "day is unaffected" do
        wt        = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                  bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                  bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                 )
        stop_time = "23:10"
        utc       = wt._create_utc_stop_time(stop_time)
        utc.day.should eql Constants::DAY
        utc.hour.should eql 23
      end
    end

    context "hour is less than 12" do
      it "day is unaffected" do
        wt        = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                  bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                  bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                 )
        stop_time = "3:10"
        utc       = wt._create_utc_stop_time(stop_time)
        utc.day.should eql Constants::DAY
        utc.hour.should eql 3
      end
    end
  end

  context "#_extract_time" do
    context "hour < 12" do
      context "minute < 10" do
        it "should return in 0X:0Xam format" do
          wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                  )
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 9, 3)
          time_str = wt._extract_time(utc)
          time_str.should eql "09:03am"
        end
      end

      context "minute > 10" do
        it "should return 0X:XXam format" do
          wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                  )
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 9, 13)
          time_str = wt._extract_time(utc)
          time_str.should eql "09:13am"
        end
      end
    end

    context "hour > 12" do
      context "minute < 10" do
        it "should return 0X:0Xpm format" do
          wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                  )
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 3)
          time_str = wt._extract_time(utc)
          time_str.should eql "07:03pm"
        end
      end

      context "minute > 10" do
        it "should return 0X:XXpm format" do
          wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                  )
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 13)
          time_str = wt._extract_time(utc)
          time_str.should eql "07:13pm"
        end
      end
    end

    context "hour == 12" do
      context "minute < 10" do
        it "should return 12:0Xpm format" do
          wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                  )
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 3)
          time_str = wt._extract_time(utc)
          time_str.should eql "12:03pm"
        end
      end
      context "minute > 10" do
        it "should return 12:XXpm format" do
          wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                   bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                   bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                  )
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 13)
          time_str = wt._extract_time(utc)
          time_str.should eql "12:13pm"
        end
      end
    end

  end

  context "#_line_we_seek?" do
    context "line does not contain trip_id we seek" do
      it "should return false" do
        wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                 bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                 bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                )
        bus_hash = {}
        bus_hash[1] = {}
        bus_hash[2] = {}
        bus_hash[3] = {}
        bus_hash[4] = {}
        result = wt._line_we_seek?(
          bus_hash: bus_hash,
          trip_id: 5,
          stop_id: 72,
          pick_up_id: 59,
          drop_off_id: 33
        )
        result.should eql false
      end

    end

    context "line does not contain stop_id we seek" do
      it "should return false" do
        wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                 bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                 bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                )
        bus_hash = {}
        bus_hash[1] = {}
        bus_hash[2] = {}
        bus_hash[3] = {}
        bus_hash[4] = {}
        result = wt._line_we_seek?(
          bus_hash: bus_hash,
          trip_id: 4,
          stop_id: 72,
          pick_up_id: 59,
          drop_off_id: 33
        )
        result.should eql false
      end

    end

    context "line contains both trip_id and stop_id we seek" do

      it "should return true" do
        wt       = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                 bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                 bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                )
        bus_hash = {}
        bus_hash[1] = {}
        bus_hash[2] = {}
        bus_hash[3] = {}
        bus_hash[4] = {}
        result = wt._line_we_seek?(
          bus_hash: bus_hash,
          trip_id: 4,
          stop_id: 59,
          pick_up_id: 59,
          drop_off_id: 33
        )
        result.should eql true
      end

    end


  end

  context "#_minute_difference" do
    it "calculates diff in minutes between  bus #2 pick-up and bus #1 drop off" do
      wt          = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                  bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                  bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                 )
      pick_up     = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 45)
      drop_off    = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 15)
      min_diff    = wt._minute_difference(bus2_pick_up: pick_up, bus1_drop_off: drop_off)
      min_diff.should eql 30.0
    end

  end

  context "#_print_times" do
    it "should output in format : pick-up-time -> drop-off-time" do
      wt             = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                     bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                     bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                    )
      times_hash     = {}
      pick_up_time   = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 45)
      drop_off_time  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 55)
      times_hash['pick_up_stop_id']  = pick_up_time
      times_hash['drop_off_stop_id'] = drop_off_time

      expect{wt._print_times(times_hash)}.not_to raise_error
      output         = wt._print_times(times_hash)
      output.should eql "05:45pm -> 05:55pm"
    end

    it "should fail with error message" do
      wt             = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                     bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                     bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                    )
      times_hash        = {}
      pick_up_time      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 45)
      drop_off_time     = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 55)
      unnecessary_time  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 22, 55)
      times_hash['pick_up_stop_id']     = pick_up_time
      times_hash['drop_off_stop_id']    = drop_off_time
      times_hash['unnecessary_stop_id'] = unnecessary_time
      expect{wt._print_times(times_hash)}.to raise_error(RuntimeError)

    end


  end

  context "#_within_desired_wait_time?" do

    context "minute diff within desired wait time" do
      it "return false" do
        wt          = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                    bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                    bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                   )
        minute_diff = 30.0
        result      = wt._within_desired_wait_time?(minute_diff)
        result.should be false
      end
    end

    context "minute diff not within desired wait time" do
      it "return true" do
        wt          = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                    bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                    bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                   )
        minute_diff = 11.0
        result      = wt._within_desired_wait_time?(minute_diff)
        result.should be true
      end
    end

  end

  context "#_create_heading" do
    context "3 digit stop id" do
      it "should have extra space" do
        wt          = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                    bus_num_1st: '1', dir_1st: Constants::OUTBOUND, pick_up_1st: '4029', drop_off_1st: '524',
                                    bus_num_2nd: '331', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '5674', drop_off_2nd: '3360'
                                   )
        output      = wt._create_heading
        output.should == "              4029    ->  524          5674   -> 3360"
      end
    end

    context "4 digit stop id" do
      it "should not have extra space" do
        wt          = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                                    bus_num_1st: '331', dir_1st: Constants::INBOUND, pick_up_1st: '2374', drop_off_1st: '4040',
                                    bus_num_2nd: '801', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '4039', drop_off_2nd: '4026'
                                   )
        output      = wt._create_heading
        output.should == "              2374    -> 4040          4039   -> 4026"
      end
    end
  end

end
