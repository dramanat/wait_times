require './wait_times'
require './segment'

describe "wait_times"do

  before(:each) {

    @seg1 = double('Segment',
                  service_type: Constants::WEEKDAY_SERVICE_ID,
                  bus_num: '1',
                  dir: Constants::OUTBOUND,
                  pick_up_stop_id: '4029',
                  drop_off_stop_id: '524',
                 )

    seg_1_bus_hash = {}
    seg_1_bus_hash[1] = {}
    seg_1_bus_hash[2] = {}
    seg_1_bus_hash[3] = {}
    seg_1_bus_hash[4] = {}
    seg_1_bus_hash[1]['4029'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17)
    seg_1_bus_hash[1]['524']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 5)
    seg_1_bus_hash[2]['4029'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 18)
    seg_1_bus_hash[2]['524']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 18, 5)
    seg_1_bus_hash[3]['4029'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19)
    seg_1_bus_hash[3]['524']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 35)
    seg_1_bus_hash[4]['4029'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 20)
    seg_1_bus_hash[4]['524']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 20, 5)
    allow(@seg1).to receive(:bus_hash) { seg_1_bus_hash }

    seg_1_trip_ids = [ 1, 2, 3, 4 ]
    allow(@seg1).to receive(:trip_ids) { seg_1_trip_ids }

    @seg2 = double('Segment',
                   service_type: Constants::WEEKDAY_SERVICE_ID,
                   bus_num: '331',
                   dir: Constants::OUTBOUND,
                   pick_up_stop_id: '5674',
                   drop_off_stop_id: '3360',
                  )

    seg_2_bus_hash = {}
    seg_2_bus_hash[5] = {}
    seg_2_bus_hash[6] = {}
    seg_2_bus_hash[7] = {}
    seg_2_bus_hash[8] = {}
    seg_2_bus_hash[5]['5674'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 30)
    seg_2_bus_hash[5]['3360']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 35)
    seg_2_bus_hash[6]['5674'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 18, 12)
    seg_2_bus_hash[6]['3360']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 18, 17)
    seg_2_bus_hash[7]['5674'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 45)
    seg_2_bus_hash[7]['3360']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 50)
    seg_2_bus_hash[8]['5674'] = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 20, 9)
    seg_2_bus_hash[8]['3360']  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 20, 14)
    allow(@seg2).to receive(:bus_hash) { seg_2_bus_hash }

    seg_2_trip_ids = [ 5, 6, 7, 8 ]
    allow(@seg2).to receive(:trip_ids) { seg_2_trip_ids }

    @wt = WaitTimes.new(segments_array: [@seg1, @seg2], want_benchmark: false)
  }

  context "#_valid_input?" do

    context "less than 2 segments received" do
      it "should fail" do
        wt2 = WaitTimes.new(segments_array: [@seg1], want_benchmark: false)
        expect{wt2.send(:_valid_input?)}.to raise_error(RuntimeError)
      end
    end

    context "2 segments received with different service types" do
      it "should fail" do
        seg3 = double('Segment',
                      service_type: Constants::SATURDAY_SERVICE_ID,
                      bus_num: '1',
                      dir: Constants::OUTBOUND,
                      pick_up_stop_id: '4029',
                      drop_off_stop_id: '524'
                     )
        wt2 = WaitTimes.new(segments_array: [seg3, @seg2], want_benchmark: false)
        expect{wt2.send(:_valid_input?)}.to raise_error(RuntimeError)
      end
    end

    context "2 segments received with same bus number" do
      it "should fail" do
        seg3 = double('Segment',
                      service_type: Constants::WEEKDAY_SERVICE_ID,
                      bus_num: '331',
                      dir: Constants::OUTBOUND,
                      pick_up_stop_id: '4029',
                      drop_off_stop_id: '524'
                     )
        wt2 = WaitTimes.new(segments_array: [seg3, @seg2], want_benchmark: false)
        expect{wt2.send(:_valid_input?)}.to raise_error(RuntimeError)
      end
    end

  end

  context "#_find_wait_times" do
    it "should have 2 items in results array" do

      @wt.send(:_find_wait_times)
      @wt.results.length.should == 2

    end
  end

  context "#_extract_time" do
    context "hour < 12" do
      context "minute < 10" do
        it "should return in 0X:0Xam format" do
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 9, 3)
          time_str = @wt.send(:_extract_time, utc)
          time_str.should eql "09:03am"
        end
      end

      context "minute > 10" do
        it "should return in 0X:XXam format" do
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 9, 13)
          time_str = @wt.send(:_extract_time, utc)
          time_str.should eql "09:13am"
        end
      end
    end

    context "hour > 12" do
      context "minute < 10" do
        it "should return in 0X:0Xpm format" do
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 3)
          time_str = @wt.send(:_extract_time, utc)
          time_str.should eql "07:03pm"
        end
      end

      context "minute > 10" do
        it "should return in 0X:XXpm format" do
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 19, 13)
          time_str = @wt.send(:_extract_time, utc)
          time_str.should eql "07:13pm"
        end
      end
    end

    context "hour == 12" do
      context "minute < 10" do
        it "should return in 12:0Xpm format" do
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 3)
          time_str = @wt.send(:_extract_time, utc)
          time_str.should eql "12:03pm"
        end
      end
      context "minute > 10" do
        it "should return in 12:XXpm format" do
          utc      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 13)
          time_str = @wt.send(:_extract_time, utc)
          time_str.should eql "12:13pm"
        end
      end
    end

  end


  context "#_minute_difference" do
    it "should find a 30 minute difference between bus #2 pick-up and bus #1 drop-off" do
      pick_up     = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 45)
      drop_off    = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 12, 15)
      min_diff    = @wt.send(:_minute_difference, start_time: pick_up, end_time: drop_off)
      min_diff.should eql 30.0
    end

  end

  context "#_print_times" do
    context "valid number of items in times_hash" do
      it "should output in format : pick-up-time -> drop-off-time" do
        times_hash     = {}
        pick_up_time   = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 45)
        drop_off_time  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 55)
        times_hash['pick_up_stop_id']  = pick_up_time
        times_hash['drop_off_stop_id'] = drop_off_time

        expect{@wt.send(:_print_times, times_hash)}.not_to raise_error
        output         = @wt.send(:_print_times, times_hash)
        output.should eql "05:45pm -> 05:55pm"
      end
    end

    context "invalid number of items in times_hash" do
      it "should fail with error message" do
        times_hash        = {}
        pick_up_time      = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 45)
        drop_off_time     = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 17, 55)
        unnecessary_time  = Time.utc(Constants::YEAR, Constants::MONTH, Constants::DAY, 22, 55)
        times_hash['pick_up_stop_id']     = pick_up_time
        times_hash['drop_off_stop_id']    = drop_off_time
        times_hash['unnecessary_stop_id'] = unnecessary_time
        expect{@wt.send(:_print_times, times_hash)}.to raise_error(RuntimeError)
      end
    end

  end

  context "#_within_desired_wait_time?" do

    context "minute diff not within desired wait time" do
      it "should return false" do
        minute_diff = 30.0
        result      = @wt.send(:_within_desired_wait_time?, minute_diff)
        result.should be false
      end
    end

    context "minute diff within desired wait time" do
      it "should return true" do
        minute_diff = 11.0
        result      = @wt.send(:_within_desired_wait_time?, minute_diff)
        result.should be true
      end
    end

  end

  context "#_create_heading" do
    context "3 digit stop id" do
      it "should have extra space" do
        output      = @wt.send(:_create_heading)
        output.should == "              4029    ->  524          5674   -> 3360"
      end
    end

    context "4 digit stop id" do
      it "should not have extra space" do
        seg3 = double('Segment',
                       service_type: Constants::WEEKDAY_SERVICE_ID,
                       bus_num: '1',
                       dir: Constants::OUTBOUND,
                       pick_up_stop_id: '4029',
                       drop_off_stop_id: '4444'
                   )
        wt2 = WaitTimes.new(segments_array: [seg3, @seg2], want_benchmark: false)
        output      = wt2.send(:_create_heading)
        output.should == "              4029    -> 4444          5674   -> 3360"
      end
    end
  end

end
