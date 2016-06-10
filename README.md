#### Purpose
Use CapitalMetro's GTFS data to find bus times that require only 5-15 minutes to wait for a connection.

Note: this program can only handle 1 bus transfer (2 buses total).

#### Explanation of code

This program uses the following GTFS data files:
- trips.txt (with fields route_id, service_id, **trip_id**, direction_id), and
- stop_times.txt (with fields **trip_id**, arrival_time, stop_id)

The following data structure is created :
- first_bus[trip_id][pick_up_stop_id] = time_at_stop
- first_bus[trip_id][drop_off_stop_id] = time_at_stop
- second_bus[trip_id][pick_up_stop_id] = time_at_stop
- second_bus[trip_id][drop_off_stop_id] = time_at_stop

Bus times are printed when :
- (second_bus[trip_id][pick_up_stop_id] - first_bus[trip_id][drop_off_stop_id]) <= 15 minutes

#### Example
Inorder to get bus times for :
- Bus #1 Southbound pick_up_stop_id 4029 and drop_off_stop_id 524, then
- Bus #331 Westbound pick_up_stop_id 5674 and drop_off_stop_id 3360

Create WaitTimes object and use its call method :
- wtimes = WaitTimes.new(svc_type: Constants::WEEKDAY_SERVICE_ID,
                   bus_num_1st: '1', dir_1st: Constants::OUTBOUND, pick_up_1st: '4029', drop_off_1st: '524',
                   bus_num_2nd: '331', dir_2nd: Constants::OUTBOUND, pick_up_2nd: '5674', drop_off_2nd: '3360'
                  )
- wtimes.call

Output:
https://docs.google.com/document/d/1NQLsBa4vuWFes-3ExZfdz8wI9Hxz2UjeOri6NMGopRQ/edit?usp=sharing

#### How to run program
1. need to have trips.txt & stop_times.txt in wait_times directory (can be downloaded from http://www.capmetro.org/gisdata/google_transit.zip)

2. need to know bus information (bus #, stop_ids, direction, etc.)

3. two options on the command prompt:
  1. ruby call_wait_times.rb
    * it has a WaitTimes object with valid input & executes the call method
  2. create WaitTimes object with valid input & use its call method (please see example)

#### Items to work on
- [ ] improve performance of #find_wait_times
- [ ] replace file processing with smarter_csv gem (file extensions need to be changed to CSV)
- [ ] create test files in spec directory and write tests for #create_bus_hash and #populate_bus_hash
- [ ] create Segment class to store bus information (will make program more scalable)
