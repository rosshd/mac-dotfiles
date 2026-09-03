---
name: home-setups
description: Maintain accurate current-state inventories of Ross's physical home setups and use them to guide compatible upgrades. Use for desk or studio equipment, computers and peripherals, displays, audio gear, docks, wiring, cable management, ergonomics, home-lab hardware, setup diagrams, hardware-spec updates, and upgrade recommendations grounded in what Ross already owns.
---

# Home Setups

Keep the canonical inventories in `/Users/ross/Documents/notes/home-setups/`.
Read the relevant inventory before answering setup questions or recommending purchases.

## Maintain an Inventory

1. Treat the inventory as a current snapshot, not a wishlist or purchase history.
2. Prefer the user's latest direct statement over old task logs, detected state, or earlier notes.
3. Edit the existing setup file in place and update its `Last updated` date.
4. Preserve confirmed details that the new information does not contradict.
5. Label facts as user-confirmed, system-detected, inferred, or unknown when provenance affects confidence.
6. Record an unknown model or dimension explicitly instead of guessing.
7. Keep upgrade pain points and missing measurements separate from owned equipment.
8. Use one Markdown file per physical setup and use short descriptive filenames.

The primary desk and studio inventory is `current-desk.md`.

## Detect Computer Hardware

Use read-only local commands such as `system_profiler`, `ioreg`, and `diskutil` when stable hardware details need refreshing.
Store the model, size, chip, CPU and GPU core counts, memory, storage capacity and type, and display model or native resolution when available.
Do not store serial numbers, hardware UUIDs, provisioning identifiers, MAC addresses, or similarly sensitive identifiers.
Do not replace user-confirmed physical topology with a stale or ambiguous system report.

## Recommend Upgrades

1. Start from the relevant inventory and its stated pain points.
2. Check dimensions, ports, signal paths, power needs, mounting constraints, and compatibility before recommending products.
3. Identify missing facts that materially affect the choice.
4. Prefer upgrades that solve documented problems and fit the existing chain.
5. Separate immediate fixes, worthwhile upgrades, and optional polish.
6. Update the inventory only after the user confirms a physical change or purchase.

## Keep the Record Useful

Use concise Markdown sections for furniture, computing, displays, input devices, audio, connectivity, pain points, and unknowns.
Include a compact connection diagram when several devices share a dock, interface, power strip, or signal chain.
Do not put private setup details in the public global-agent repository.
