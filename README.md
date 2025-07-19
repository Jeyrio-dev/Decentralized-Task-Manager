# Decentralized Task Manager

A Clarity smart contract for creating and managing tasks on the Stacks blockchain.

## Overview
This project implements a decentralized task manager where users can:
- Create tasks with a description (up to 100 characters).
- Mark tasks as completed.
- View task details.

## Contract Details
- **File**: `task-manager.clar`
- **Functions**:
  - `(create-task description)`: Creates a new task with a given description.
  - `(complete-task task-id)`: Marks a task as completed (only by the task owner).
  - `(get-task task-id)`: Retrieves task details.

## Getting Started
1. Clone the repository.
2. Run `clarinet check` to verify the contract.
3. Deploy to a Stacks testnet using Clarinet or Hiro's tools.
4. Integrate with a front-end to interact with tasks.

## Testing
Use Clarinet to write tests:
```bash
clarinet test