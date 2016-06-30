require 'pry'
require './segment'

describe "segment" do

  before(:all) {
    @seg1 = Segment.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                       bus_number: '1',
                       bus_dir: Constants::OUTBOUND,
                       pick_up_id: '4029',
                       drop_off_id: '524'
                      )

  }

  context "#_line_we_seek?" do
    context "line does not contain trip_id we seek" do
      it "should return false" do
        @seg1.bus_hash[1] = {}
        @seg1.bus_hash[2] = {}
        @seg1.bus_hash[3] = {}
        @seg1.bus_hash[4] = {}
        result = @seg1.send(:_line_we_seek?,
          trip_id: 5,
          stop_id: '72',
        )
        result.should eql false
      end

    end

    context "line does not contain stop_id we seek" do
      it "should return false" do
        @seg1.bus_hash[1] = {}
        @seg1.bus_hash[2] = {}
        @seg1.bus_hash[3] = {}
        @seg1.bus_hash[4] = {}
        result = @seg1.send(:_line_we_seek?,
          trip_id: 4,
          stop_id: '72',
        )
        result.should eql false
      end

    end

    context "line contains both trip_id and stop_id we seek" do

      it "should return true" do
        @seg1.bus_hash[1] = {}
        @seg1.bus_hash[2] = {}
        @seg1.bus_hash[3] = {}
        @seg1.bus_hash[4] = {}
        result = @seg1.send(:_line_we_seek?,
          trip_id: 4,
          stop_id: '4029',
        )
        result.should eql true
      end

    end

  end

  context "#_create_utc_stop_time" do

    context "hour is greater than 24" do
      it "increments day and subtracts 24 from hour" do
        stop_time = '25:10'
        utc       = @seg1.send(:_create_utc_stop_time, stop_time)
        tomorrow = Time.now + (24 * 60 * 60 )
        utc.day.should eql tomorrow.day
        utc.hour.should eql 1
      end
    end

    context "hour is less than 24" do
      it "day is unaffected" do
        stop_time = "23:10"
        utc       = @seg1.send(:_create_utc_stop_time, stop_time)
        utc.day.should eql Constants::DAY
        utc.hour.should eql 23
      end
    end

    context "hour is less than 12" do
      it "day is unaffected" do
        stop_time = "3:10"
        utc       = @seg1.send(:_create_utc_stop_time, stop_time)
        utc.day.should eql Constants::DAY
        utc.hour.should eql 3
      end
    end
  end
end
