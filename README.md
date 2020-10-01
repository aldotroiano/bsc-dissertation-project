# Mobile Multiplayer Networked game optimised for unreliable connections

The project was developed as the Final Year BSc Computer Science dissertation.

Project submitted the 25th of May 2020 at the University of Reading

**Final Grade: First Class Honours**

The repository contains two Applications:
- Client: Client Mobile Application written in Lua
- Server: Server Backend Application written in Javascript (NodeJS framework) with local mysqlite3 database.

## Project articulation and objectives

The goal of this project is to build a 2D networked game with multiplayer capability, enabling users to both play in single player mode and in multiplayer mode with up to three other players, bringing the total maximum users playing together to four.  The users can either select their opponents either by entering the same lobby using a team name or by entering the global matchmaking room, having the Server initiate matches between selected players based on the average round-trip time between the Server and the Clients. In addition, an equally important project specification consists in the optimisation of the overall game’s reliability by asserting that each packet is received by both the Client and the Server in order to provide the users with a synchronised view of the match.  
To achieve such objective, an optimisation solution must be designed and developed for both the Client, in terms of the packet receival process minimising hardware overhead, and for the Server which increases throughput compressing packets and reduces their size. The Server Application should also be responsible for terrain generation and transmission to Clients.  Being that it will support multiple matches taking place concurrently, the Server should keep a record of the connected Clients by storing their addresses and should be able to communicate to both a single player individually and broadcast to a set of players in a match.

The objectives of this report were first outlined in the Project Initiation Document available in the Appendix section.  As far as the Client is concerned, in order to achieve a fully functioning real-time multiplayer game, the following objectives should be fulfilled. Firstly, the Client Application containing the game environment should be cross-platform, deployable to mobile devices: iOS and Android, and also possibly Desktop platforms such as Windows and macOS, presenting a clear and simple interface for all levels of user experience. The Application should allow a maximum of 4 players to enter the same match: each of them represented by a spaceship entity and in the game environment, reflecting in real-time the inputs of each individual user. Thrusted by a physics-controlled motor, each of these spaceships is directed towards the path envisioned by using user input coordinates. 
Each Match between the Players will unfold vertically, having as an objective to reach the Finish line and preserve the Health level. The latter is reduced through the spaceship’s collisions with obstacles and asteroids that are part of the terrain generated by the Server and synchronised between the players. 
Moreover, the terrain includes Boost entities that provide a short increase in the spaceship’s speed.                        At the same time, it includes a Lobby screen carrying information on the other team participants along with a Team creation screen in which the user is able to select a team name and username.  
The first user to enter the team gains the host property, enabling him to decide when to start the game.  The Client Application should also include a matchmaking option where players are assigned their opponents, selected based on their network latency parameters.  
The chosen development platform should include a game engine capable of detecting real-time physics collision and low-level network socket management. One must underline the fact that the Server Application requires an equivalent level of attention. 
On one hand, given that it is cloud-hosted, this enables Clients to connect through a Static Public IP address. On the other hand, it is responsible for storing the Client data such as IP addresses along with serving the Clients with team data and configuring the match. The match configuration includes methods such as terrain generation (obstacles, boosts and asteroids), the selection of a host for each team that decides when to start a game and lastly the assessment of user connection status. One must note that Clients may play on Local Area Networks (LANs) and on cellular networks such as 3G and 4G networks.
  
Given that the project includes several objectives, many of which have required a significant amount of hardware specifications and network requirements, there are also a number of constraints that can be outlined: a real-time multiplayer game requires multiple devices to interact simultaneously through user inputs and have an internet connection.  Therefore, one of the constraints has consisted in testing the multiplayers’ functionality as well as the Server’s limited hardware capabilities have surely impacted upon the performance of the game on the Client-side.

