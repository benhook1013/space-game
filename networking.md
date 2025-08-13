# 🌐 Networking (Future)

Multiplayer is not part of the MVP but the design allows a
host-authoritative model later. See [PLAN.md](PLAN.md) for how networking fits
into the long-term roadmap.

## Overview

- One player simulates the world; others connect over local network WebSockets.
- Actions are exchanged as JSON packets, e.g.
  `{ "type": "move", "payload": {...} }`.
- No NAT traversal or central server; peers connect via QR code or direct IP.

## Goals

- Reuse the same systems for offline and online play.
- Keep protocol definitions in a shared module.

This document will expand once multiplayer work begins.
