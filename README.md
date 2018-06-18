# Shiny Music Player

https://apps.cultureofinsight.com/shiny-music-player/

This app is an example of how you can use shiny to collate a data base of music from URLs of various music streaming sites such as Soundcloud, YouTube, Bandcamp and Mixcloud.

The interface can then be used to explore your collection and load embed versions of the URLs provided into an in-app iframe.

This could be useful if you are into independent or unreleased music that may only be available on YouTube, Soundcloud or Bandcamp, and not the major streaming services like Spotify or Apple Music. The app does accept Spotify URLs but their embed player limits songs to 30 second previews.

## How it works

When you provide a URL to the app, it will scrape the HTML and pull out the following meta properties:

* title
* description
* image
* embed url (twitter::player)

This data is then appended to a private remote google sheets data base and re-read into the interactive data table within the app.

Clicking on a track within the table will load the embed URL into an iframe at the bottom of the sidebar and the song will be played.

Feel free to add some tracks to the library and test out the functionality!

## Personalise your own version

This boiler-plate example is designed to be used as the base code for you to build your own version and start building your own library of music.

You may want to add more user inputs to provide additional data for each track, such as genre, date of release, comments, tags etc.

For example, I share a private version with 3 other friends with a library of over 2,000 tracks going back 3 years. Each track has data on who posted it, and we use date and genre filters to quickly explore the library.

If you want to run the app locally or on your own cloud server, you have the option of saving data to a local file. Deploying on shinyapps.io will require some form of remote data storage such as google sheets or MySQL.

## Credits

* The meta property scraping code was taken from this [stack overflow answer](https://stackoverflow.com/a/27864360/7531364) courtesy of Bob Rudis (@hrbrmstr)
* The busy indicator code that runs when adding a track to the library was taken from Dean Attali's [advanced-shiny/busy-indicator repo](https://github.com/daattali/advanced-shiny/tree/master/busy-indicator)

## Contributions

I'd be keen to make this an open-source effort, so if you have any ideas for feature improvements or bug fixes, pull requests would be very welcome!

The original inspiration for this app was for it to replace a private facebook group I used to share music with friends. The ultimate aim would be to have the functionality for users to interact with each song post with 'likes', comments etc, as they would do on facebook.

Known Bugs:

* If a row in the data table has been selected, adding a new track to the table and trying to load the track that now occupies the same table index as the previous selection (which is now a different track because it is sorted in descending date order) does not work.

Thanks!

[Paul Campbell](https://github.com/paulc91)
