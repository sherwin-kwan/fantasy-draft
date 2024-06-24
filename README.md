# FANTASY DRAFT PLAYER RANKER

Use this to set up draft rankings for a points-only hockey pool. (I created this for a specific pool with unique rules, many of which are hard-coded into this project.
You are free to modify this for other pools with other systems, this is FOSS.)

`start.rb` is the main entry point for this app. Comment/uncomment the scripts you want to include.

These scripts scrape Cap Friendly and NHL.com's API for data, along with fantasy hockey guides. It outputs a list of players in order of points they are likely to deliver,
which will appear in the file `export.csv`

Before running the app, ensure that the algorithm for calculating scores has been entered into the Player class
You will also need to set the `NUM_MANAGERS` constant to the number of teams in the pool.

