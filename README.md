# Hotel data merge - solution

## Introduction

This is an attempt to [this coding challenge](https://kitt.lewagon.com/db/123650). To access the deliverable, you can access these links:

- [Return all hotels from three different suppliers](https://strawberry-cupcake-14846-16923e053e31.herokuapp.com/api/hotels)
- [Return specific hotels by hotel's "id"](https://strawberry-cupcake-14846-16923e053e31.herokuapp.com/api/hotels?hotels=SjyX,f8c9) (e.g. URL?hotels=comma-separated-hotel-slugs)
- [Return specific hotels by hotel's "destination_id"](https://strawberry-cupcake-14846-16923e053e31.herokuapp.com/api/hotels?destinations=5432) (e.g. URL?destinations=comma-separated-hotel-destination-ids)
- [Return specific hotels by hotel's "id" and "destination_id" combination](https://strawberry-cupcake-14846-16923e053e31.herokuapp.com/api/hotels?destinations=5432&hotels=SjyX) (e.g. URL?hotels=??&destinations=??)

### Local setup 

- run `rails db:setup`
- run in `rails c` -> `HotelProcurer.new.call`
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
- It's assumed in this solution that "id" actually refers to the hotel "slug". The downloaded data will still have the auto-incrementing `id`.
- It's possible for the same hotel to have different `destination_id`
- It's assumed that once the data no longer exists in the supplier's response payload, the existing data stored in the DB should be removed

#### V0 (Server setup and initial data cleanup)

- ~~Please see [this repo](https://github.com/primaulia/hotel-cleanup-api) for the procuring process~~ **This setup is dropped with reasons mentioned above**
- ~~Setup GraphQL: Decided that it will make the API more flexible in the future~~ **This setup is dropped, to simplify the solutions**
- Setup class diagram based on the API response example  

![Screenshot 2024-04-01 at 10 22 27 PM](https://github.com/primaulia/hotel_data_api/assets/1294303/48d882a3-46fb-4dbd-ab51-47eba41de7a6)
- This is the intuition behind the current procuring system
  
![Screenshot 2024-04-01 at 10 14 24 PM](https://github.com/primaulia/hotel_data_api/assets/1294303/4eca79c1-8f12-41d0-aff4-50deaccc8dd9)


#### V1 Code refactoring
- As the Python flask setup is dropped, proceed to clean data with Rails service instead
- Write appropriate tests in rspec across the system
- Improve the readability of the code

#### V2 Improvements
- As there are possibilities that the data doesn't provide any coordinates for the map. Introduce the `geocoder` gem to fill the empty value
- Introduce a simple cache on the response endpoint
- Setup a deployed server for testing purposes

#### V3 Refactor
- Implement refactoring in the procurement process. So now the data from suppliers are all immediately stored in the DB
- If the data has been stored in the DB, the code will check the difference so we also remove the intensive deduplication process
- Also create a fallback processor in case we have yet to create a specific processor for a new supplier source
- TODO: **the unit test hasn't been updated accordingly to this refactor**

![Screenshot 2024-04-23 at 11 34 23 PM](https://github.com/primaulia/hotel_data_api/assets/1294303/8cdee3dd-60c5-43e5-ac02-5a1c6490f78f)
