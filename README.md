# Hotel data merge - solution

## Introduction

This is an attempt to [this coding challenge](https://kitt.lewagon.com/db/123650). To access the deliverable, you can access these links:

- Return all hotels from three different suppliers
- Return specific hotels by hotel's "id"
- Return specific hotels by hotel's "destination_id"
- Return specific hotels by hotel's "id" and "destination_id" combination

### Local setup 

- run `rails db:setup`
- run in `rails c` -> `DataDownloader.new.call`
- stop the console and start the rails server
- Go to the links mentioned above with localhost as the base host

## Setup

### Programming languages

- ~~Python (Flask)
  reasoning: the most efficient language to perform the data cleanup process. The Flask server will provide a single API endpoint that returns the cleaned API response based on the multiple supplier API~~
  Dropped Python element to simplify the solution
- Ruby on Rails
  reasoning: to match the stack used in Ascenda and also the fastest to set up for a simple API endpoint provider

### Approaches

#### Assumptions
- There are three suppliers API endpoints to be called, but there are possibilities that some API endpoints will be omitted and/or new API endpoints to be introduced
- It's possible for the same hotel to have different `destination_id`

#### V0 (Server setup and initial data cleanup)

- ~~Please see [this repo](https://github.com/primaulia/hotel-cleanup-api) for the procuring process~~ **This setup is dropped**
- Setup class diagram based on the API response example  
![Screenshot 2024-03-28 at 9 49 13 AM](https://github.com/primaulia/hotel_data_api/assets/1294303/06a5d16d-ad1a-4e72-985f-a6ce3adeea89)
- ~~Setup GraphQL: Decided that it will make the API more flexible in the future~~ **This setup is dropped**
- This is the intuition behind the current procuring system
![Screenshot 2024-04-01 at 10 14 24 PM](https://github.com/primaulia/hotel_data_api/assets/1294303/4eca79c1-8f12-41d0-aff4-50deaccc8dd9)


#### V1 Code refactoring
- As the Python flask setup is dropped, proceed to clean data in Rails instead
- Write appropriate tests in rspec across the system
- Improve the readability of the code

#### V2 Improvements
- As there are possibilities that the data doesn't provide any coordinates for the map. Introduce `geocoder` gem to fill the empty value
- Introduce a simple cache on the response endpoint

#### Future improvements



