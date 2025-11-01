# celo_p2e — Play-to-Earn on Celo

![celo_p2e hero image](./assets/hero.png)

Project: celo_p2e  
Author: Pham Le Dinh An

## Project description
celo_p2e is a simple play-to-earn dApp on the Celo blockchain. Smart contracts manage game configuration, staking, scoring, and rewards. Players stake a fixed amount to start a round, submit scores, and winners earn on-chain rewards recorded in the owner contract. An auxiliary logger contract stores play history for analytics. The frontend connects wallets, shows game state, lets players stake, play, view scores, and claim rewards. Admin tools let the owner fund the game, set targets and rewards, and authorize the game contract for recording wins.

## Vision
Create a straightforward, fair play-to-earn game that lets players earn real value by playing. With clear on-chain rules, transparent payouts, and Celo’s low-cost transactions, the project can open new income paths for casual players and small creators. Over time, analytics and reputation features can grow communities, enable tournaments, and attract sponsors. The goal is a scalable, trustworthy game economy that returns value directly to players while keeping operations secure and auditable.

## Development plan (high level)
1. Contracts design — define GameOwner, PlayerGame, OwnerPlayer. Key state: owner, stakeAmount, rewardAmount, targetScore, playerGame (authorized), rewards mapping, playerScores, hasStaked, interactions. Add events and modifiers (onlyOwner, onlyPlayerGame).
2. Core contracts — implement GameOwner (update config, fundGame, setPlayerGame, recordWin, claimReward), PlayerGame (startGame payable, finishGame, receive), OwnerPlayer (recordInteraction, setter).
3. Security & tests — add checks, avoid reentrancy, add unit tests for stake/finish/record/claim and unauthorized access.
4. Frontend — wallet connect, UI for stake/submit score/claim, admin panel, view play history via OwnerPlayer.
5. Integration & monitoring — CI, gas checks, logging, analytics.
6. Deployment — deploy contracts to Celo, set playerGame address on GameOwner, publish frontend.

## Personal story
Pham Le Dinh An built this game to create accessible, honest earning opportunities via blockchain. Motivated by real income for casual players, he designed a minimal, secure system where players stake, play, and claim rewards with transparent rules.

## Install & run (developer)
Prerequisites
- Node.js >= 18, npm or yarn
- Hardhat
- (Optional) Celo RPC URL and a deployer private key

Install
```bash
npm install
# or
yarn
```

Compile
```bash
npx hardhat compile
```

Run local node
```bash
npx hardhat node
```

Run tests
```bash
npx hardhat test
```

Deploy locally
```bash
npx hardhat run --network localhost scripts/deploy.js
```

Deploy to Celo
- Set env vars: PRIVATE_KEY, CELO_RPC_URL (or use hardhat-keystore)
- Update networks in hardhat.config.js
```bash
# example using env
npx hardhat run --network celo scripts/deploy.js
```

Frontend
```bash
cd frontend
npm install
npm run dev
```

Support
- Open an issue for bugs or feature requests.