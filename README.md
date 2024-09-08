
![Logo](https://github.com/AlshehriAbdullah1/IronSight_Project/blob/main/IronSight%20Logo.png?raw=true)
# IronSight 

A  platform designed to connect the Esports community by providing a centralized hub for tournament
management, community engagement, and player interaction.



## Features

- Tournament Management: Create and full control of tournament, players and view dashboard and more!
- Communities Management: Manage tournaments through moderators, post content and upload media!
- Games: View games and the associated tournaments!
- Profile: View and manage your profile!
- Admin Dashboard: View and monitor tournaments, users reports and game suggestions!
------------------------------------------------------------------------------------------------
## Tech Stack

**Client Side:** Flutter, React, TailwindCSS, Riverpod2.0

**Server Side:** NodeJS, Express, Google Cloud Platform, Docker


## Contributors 

 - [Abdulrahman171](https://github.com/Abdulrahman171)
 - [ Hamza Fadil [AprilXS]](https://github.com/AprilXS)
 - [ Hussain Ibrahim ](https://github.com/almakrami)
 - [ Turki Alduhami ](https://github.com/oTariko)
 - [  Sufyan Alhammad  ](https://github.com/sofianmh)


## How to run it

How to run the Backend

1- cd to Backend folder, then type: npm i
```bash
  npm i
```

2- Then type:
```bash
  npm install -g concurrently
```
3- Then install node_modules, by typing:
```bash
  npm run i
```
4- For nodemon all server, type: 
```bash
 npm run dev
```


How to run React
1- cd to /Frontend/React, then type:
```bash
 npm i
```
2- Type: 
```bash
npm run dev
```
## Environment Variables

To run this project, you will need to add the following environment variables to your .env file
(be aware of some of the links that may contain localhost, may need to be changed)

in FrontEnd/flutter_app/.env add : 

`API_URL`,
`API_TOKEN`,
`GOOGLE_CLOUD_CLIENT_ID`,
`GOOGLE_OAUTH_REDIRECT_URL`,
`GOOGLE_ROOT_URL`,
`START_GG_CLIENT_ID`,
`START_GG_REDIRECT_URL`,
`START_GG_ROOT_URL`,



in FrontEnd/React/.env add : 

`VITE_APP_BASE_URL`


in BackEnd/.env add : 

`API_FLUTTER_PORT=3001`,
`API_REACT_PORT=3002`,
`TOURNAMENT_PORT=4001`,
`USER_PORT=4002`,
`GAME_PORT=4003`,
`COMMUNITY_PORT=4004`,
`MEDIA_PORT=4005`,
`CHAT_PORT=4006`,
`SEARCH_PORT=4007`,
`ADMIN_PORT=4008`,

`API_FLUTTER_HOST=http://localhost:3001`,
`API_REACT_HOST=http://localhost:3002`,
`TOURNAMENT_HOST=http://localhost:4001`,
`USER_HOST=http://localhost:4002`,
`GAME_HOST=http://localhost:4003`,

`COMMUNITY_HOST=http://localhost:4004`,
`MEDIA_HOST=http://localhost:4005`,
`CHAT_HOST=http://localhost:4006`,
`SEARCH_HOST=http://localhost:4007`,
`ADMIN_HOST=http://localhost:4008`,

`REDIRECT_URL=https://localhost`,
`port = process.env.API_FLUTTER_PORT`,

`TournamentMicro = process.env.TOURNAMENT_HOST;`,
`UserMicro = process.env.USER_HOST;`,
`GameMicro = process.env.GAME_HOST;`,

`CommunityMicro = process.env.COMMUNITY_HOST;`,
`SearchMicro = process.env.SEARCH_HOST;`,
`port = process.env.API_REACT_PORT`,

`TournamentMicro = process.env.TOURNAMENT_HOST;`,
`UserMicro = process.env.USER_HOST;`,
`GameMicro = process.env.GAME_HOST;`,

`CommunityMicro = process.env.COMMUNITY_HOST;`,
`AdminMicro = process.env.ADMIN_HOST;`,
`port = process.env.ADMIN_PORT`,

`port = process.env.COMMUNITY_PORT`,
`MediaMicro = process.env.MEDIA_HOST;`,
`port = process.env.GAME_PORT`,

`MediaMicro = process.env.MEDIA_HOST;`,
`port = process.env.MEDIA_PORT`,
`port = process.env.SEARCH_PORT`,

`port = process.env.TOURNAMENT_PORT`,
`MediaMicro = process.env.MEDIA_HOST;`,
`port = process.env.USER_PORT`,

`MediaMicro = process.env.MEDIA_HOST;`,
`axios.defaults.baseURL = process.env.API_REACT_HOST;`,
`URLschedule = process.env.TOURNAMENT_HOST + /tournamentM/checkStart`,
