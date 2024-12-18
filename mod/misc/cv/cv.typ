#import "template.typ": *

#show: resume.with(
  author: "Kleidi Bujari",
  email: "mail@4kb.net",
  github: "github.com/kbujari",
  personal-site: "4kb.net",
  paper: "us-letter",
)

== Education

#edu(
  institution: "Toronto Metropolitan University",
  dates: dates-helper(start-date: "Sep 2020", end-date: "Apr 2025"),
  location: "Ontario, Canada",
  degree: "Bachelor's of Engineering, Computer Engineering",
)

- *Relevant Coursework*:
  Data Structures, Embedded Programming, Compilers, Digital Systems, Computer Networks
- *Extracurriculars*:
  Member of student robotics design team,
  teaching assistant for micro-processor courses.

== Experience

#work(
  company: "Toronto Metropolitan University",
  title: "Graduate Research Assistant",
  dates: dates-helper(start-date: "May 2024", end-date: "Sep 2024"),
  location: "Toronto, Canada",
)

- Implemented transformations for hundreds of media files,
  using ffmpeg and unix primitives to parallelize workload.
- Designed frontend with AstroJS to generate only static HTML,
  ensuring compatibility with many hosting providers.

#work(
  company: "Canadian Broadcasting Corporation",
  title: "Network Engineering Intern",
  dates: dates-helper(start-date: "May 2023", end-date: "Apr 2024"),
  location: "Toronto, Canada",
)

- Designed custom PXE-boot implementation for hundreds of devices using NetBox,
  eliminating manual configuration.
- Configured Hyper-Converged Proxmox cluster for 2024 Olympics,
  saving \$250k+ with reused hardware and open software.
- Deployed vendor-agnostic routing observability from scratch,
  with Prometheus metrics and Grafana dashboards.
- Mentored junior application developers in modern C++23 programming,
  aiding in performance design and memory safety.

#work(
  company: "WSP Canada",
  title: "Student Engineer",
  dates: dates-helper(start-date: "May", end-date: "Aug") + ", 2021, 2022",
  location: "Toronto, Canada",
)

- Contributed to subway car control systems with modern C++20,
  replacing legacy code with newer STL functions.
- Extended internal distributed filesystem with support for deduplication and compression,
  reclaiming 30% of storage.
- Validated new electrical designs for power consumption,
  cost efficiency, and viability with existing systems.
- Participated in reviewing and adjusting large scale electrical and structural engineering designs.

== Projects

*Custom Linux Distribution* ---
Designed entire Linux distribution used for hosting production servers,
daily desktop use, and embedded programming on a Raspberry Pi.
Using NixOS, it supports enabling only required functionality at build time.
Features systemd,
an in-memory root filesystem,
ZFS persistent storage with backups,
and extremely hardened networking.

*ICER Compressor* ---
Image compression library written in Rust,
designed for deep-space communication.
Hand tuned for speed and portability by using only integer arithmetic,
no heap allocations, and no standard library by default.
Achieves practically instant compressions, even on microprocessors.

*Kubernetes Cluster* ---
Bare-metal compute cluster managed with GitOps to be completely reproducible.
Uses Cilium CNI for fast eBPF networking and BGP load balancing,
FluxCD for cluster management,
and CEPH distributed storage for stateful workloads.
Running Prometheus, Loki and AlertManager for complete observability.

*Mirrorlist Generator* ---
Fetches Arch Linux package mirrors,
filtering them based on user parameters.
Sorts and outputs formatted data compliant with the pacman package manager.
Heavily outperforms default Python implementation.

*Toronto Metropolitan Robotics* ---
Member of university design team working on space focused automated robotics.
Designed custom STM32 hardware with various interfaces (SPI, I2C, etc.) for controlling motor functions on robot.
Worked alongside various subteams to deliver a competition ready autonomous system.

== Skills

- *Languages*: #(
    "Rust",
    "C++",
    "Nix",
    "Haskell",
    "TypeScript",
    "Lua",
    "Python",
  ).join(", ")

- *Technologies*: #(
    "Linux",
    "Compilers",
    "Virtualisation",
    "Terraform",
    "Ansible",
    "Computer Networks",
    "Frontend (Svelte, Astro)"
  ).join(", ")
