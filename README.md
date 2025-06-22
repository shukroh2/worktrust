
## Features

- **User Registration & Staking:** Register as a client or freelancer, set a profile, and stake tokens.
- **Job Management:** Clients create jobs with milestones and lock payment in escrow.
- **Milestone Submission & AI Grading:** Freelancers submit work; AI oracles can grade submissions.
- **Dispute Resolution:** Disputes are handled by a DAO jury system.
- **Reputation & DID:** Users earn reputation NFTs based on performance and participation.
- **Freelancer Auctions:** Freelancers can start auctions for their services.
- **DAO Proposals:** Community-driven proposals and voting.
- **Referrals & Subscriptions:** Referral system and paid subscription tiers.

## Contract Structure

- Contract: worktrust.clar
- Tests: worktrust.test.ts

## Key Functions

- `register(role, profile-uri)`: Register a new user.
- `stake-tokens(amount)`: Stake tokens to participate.
- `create-job(freelancer, milestones, total)`: Client creates a job.
- `submit-milestone(job-id, ms-id, uri)`: Freelancer submits milestone work.
- `oracle-grade(job-id, ms-id, score)`: Oracle grades a milestone.
- `raise-dispute(job-id, ms-id)`: Raise a dispute for a job.
- `vote-dispute(job-id, ms-id, decision)`: DAO jurors vote on disputes.
- `update-reputation(user, delta)`: Update a user's reputation.
- `start-auction(min-bid)`: Freelancer starts an auction.
- `place-bid(freelancer, amount)`: Place a bid in an auction.
- `submit-proposal(title)`: Submit a DAO proposal.
- `vote-proposal(id, vote)`: Vote on a DAO proposal.
- `execute-proposal(id)`: Execute a passed proposal.
- `subscribe(tier, duration)`: Subscribe to a paid tier.
- `refer(new-user)`: Refer a new user.

## Development

### Requirements

- [Clarinet](https://docs.hiro.so/clarinet/get-started/installation)
- Node.js & npm

### Install Dependencies

```sh
npm install
```

### Check Contracts

```sh
clarinet check
```

### Run Tests

```sh
npm test
```

or for coverage and cost reports:

```sh
npm run test:report
```

## Project Structure

- contracts: Clarity smart contracts.
- tests: Vitest-based unit tests.
- settings: Network and account configuration.
- Clarinet.toml: Project manifest.

