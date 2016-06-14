#### Purpose
Make your bus commute easier!  Find routes that require only 5-15 minutes of wait time between transfers.  (Only works for trips with just one transfer.)

This program can be used by any public transit system who publish their transit data in GTFS (General Transit Feed Specification) format.

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
call_wait_times.rb finds bus times with 5-15 minutes wait for :
- Bus #1 Southbound pick_up_stop_id 4029 and drop_off_stop_id 524, then
- Bus #331 Westbound pick_up_stop_id 5674 and drop_off_stop_id 3360

[Output from call_wait_times.rb](https://docs.google.com/document/d/1NQLsBa4vuWFes-3ExZfdz8wI9Hxz2UjeOri6NMGopRQ/edit?usp=sharing)

#### How to use program
1. need to have trips.txt & stop_times.txt in wait_times directory 
  1. Austin's Capital Metro GTFS feed can be downloaded from http://www.capmetro.org/gisdata/google_transit.zip
  2. GTFS feeds for other cities can be found at https://code.google.com/archive/p/googletransitdatafeed/wikis/PublicFeeds.wiki

2. need to know bus information (bus #, stop_ids, direction, etc.)

3. to print results, use call_wait_times.rb as an example to
  1. set up 2 Segment objects
  2. create WaitTimes object with Segment objects passed in as an array
  3. execute WaitTimes' call method

#### Items to work on
- [X] create test for #find_wait_times
- [ ] improve performance of #find_wait_times
- [ ] replace file processing with smarter_csv gem (file extensions need to be changed to CSV)
- [ ] create test files in spec directory and write tests for #create_bus_hash and #populate_bus_hash
- [X] create Segment class to store bus information (will make program more scalable)
