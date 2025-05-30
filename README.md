# MedSupplyTrack

A blockchain-based medical supply chain tracking system built on the Stacks blockchain.

## Overview

MedSupplyTrack provides end-to-end visibility and verification for medical supplies, from manufacturer to patient. The system ensures the authenticity and quality of medical products by tracking custody transfers and environmental conditions throughout the supply chain.

## Features

- Complete chain-of-custody tracking for medical supplies
- Environmental condition monitoring (temperature, humidity)
- Expiration date tracking and alerts
- Verification of product authenticity
- Real-time status updates

## Smart Contract Functions

- `register-item`: Add a new medical supply item to the system
- `transfer-custody`: Record a transfer of custody between supply chain participants
- `update-status`: Update the status of an item (e.g., "in transit", "delivered")
- `get-item-details`: Retrieve complete information about a medical supply item
- `get-custody-event`: View details of a specific custody transfer event
- `is-expired`: Check if a medical supply item has expired

## Getting Started

1. Clone this repository
2. Install Clarinet: `npm install -g @stacks/clarinet`
3. Run tests: `clarinet test`

## Use Cases

- Tracking temperature-sensitive vaccines
- Verifying the authenticity of medical devices
- Monitoring the chain of custody for controlled substances
- Ensuring proper handling of sensitive medical equipment
