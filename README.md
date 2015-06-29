# GPSearch
Google Places Search Application

Hello Dave,

It was nice talking to you last week. As a next step I would like you to work on the following coding exercise and send it back to me as soon as you can.

An application with Table View and Search bar on top of it. 
I should be able to search for a term by typing my query inside the search bar. 

Once I click on the search button, it makes a call to google places api (Text Search Requests) and fetch the results. I would like you to use their REST API.

Request should have the four parameters

key
query
location 
radius

Please grab the user current location using Core Location API, specify the radius as 2500 meters as hardcoded. 

Each cell of the table are going to display the following:
1) icon 
2) name
3) opening hours
4) vicinity
5) types

Things to consider
1) Code needs to be modular 
2) Table view needs to be smooth while scrolling
3) Indefinite scrolling if there are lot of news article for a given search rearm.
