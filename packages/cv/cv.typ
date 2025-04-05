#set document(author: "Kleidi Bujari", title: "Kleidi's Resume!")
#set text(size: 10pt, lang: "en", ligatures: false)
// #set page(margin: 0.5in, paper: "us-letter")

#show link: underline
#set par(justify: true)

#show heading.where(level: 1): it => [
  #set text(weight: 700, size: 20pt)
  #pad(it.body)
]

#show heading.where(level: 2): it => [
  #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
  #line(length: 100%, stroke: 1pt)
]

#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = [
  #strong(top-left) #h(1fr) #top-right \
  #bottom-left #h(1fr) #bottom-right
]

#let dates-helper(from: "", to: "") = from + " " + $dash.em$ + " " + to

#let edu(
  institution: "",
  dates: "",
  degree: "",
  location: "",
) = generic-two-by-two(
  top-left: institution,
  top-right: dates,
  bottom-left: degree,
  bottom-right: location,
)

#let work(
  title: "",
  dates: "",
  company: "",
  location: "",
) = generic-two-by-two(
  top-left: title,
  top-right: dates,
  bottom-left: company,
  bottom-right: location,
)

= Kleidi Bujari

#(
  link("mailto:mail@4kb.net"),
  link("https://github.com/kbujari")[github.com/kbujari],
  link("http://kleidi.ca")[kleidi.ca],
).join("  |  ")

== Experience

/*
#work(
  company: "Meta",
  title: "Production Engineer",
  dates: dates-helper(from: "Jul 2024", to: "Present"),
  location: "Menlo Park",
)

- Worked on Linux kernel and Erlang's BEAM virtual machine,
  shipping performance optimizations directly to upstream projects.
- Built foundational messaging infrastructure running WhatsApp core systems worldwide,
  improving reliability and performance.
*/


#work(
  company: "Toronto Metropolitan University",
  title: "Graduate Research Assistant",
  dates: dates-helper(from: "May 2024", to: "Sep 2024"),
  location: "Toronto",
)

- Organized webhosting and analytics for a large film release,
  leading design of web presence for thousands of concurrent visitors.
- Automated transformations for hundreds of media files,
  using ffmpeg and unix primitives to parallelize workload.
- Published frontend with AstroJS to generate only static HTML,
  ensuring compatibility with many hosting providers.

#work(
  company: "Canadian Broadcasting Corporation",
  title: "Network Engineering Intern",
  dates: dates-helper(from: "May 2023", to: "Apr 2024"),
  location: "Toronto",
)

- Designed custom PXE based provisioning for hundreds of devices on existing network,
  eliminating manual configuration.
- Architected hyper-converged Proxmox cluster for 2024 Olympics,
  saving \$250k+ with reused hardware and open software.
- Mentored junior application developers in modern C++ programming,
  aiding in memory safety and performance design.

#work(
  company: "WSP Canada",
  title: "Student Engineer",
  dates: dates-helper(from: "May", to: "Aug") + ", 2021, 2022",
  location: "Toronto",
)

- Modernized subway control systems with modern C++,
  replacing legacy code with newer STL functions and safer standards.
- Validated large-scale electrical designs for power consumption,
  cost efficiency, and viability with existing systems.
- Extended internal distributed databases with compression and deduplication,
  reclaiming terabytes of storage across entire org.

== Projects

*Custom Linux Distribution* ---
Designed entire Linux distribution used for hosting production servers,
daily desktop use, and embedded programming on a Raspberry Pi.
Using NixOS, it supports enabling only required functionality at build time.
Features systemd,
an in-memory root filesystem,
ZFS persistent storage with backups,
and extremely hardened networking.

*Distributed Compute Cluster* ---
Bare-metal Kubernetes cluster managed with GitOps to be completely reproducible.
Uses Cilium CNI for fast eBPF networking and BGP load balancing,
FluxCD for cluster management,
and CEPH distributed storage for stateful workloads.
Air-gapped, automated cluster provisioning with custom PXEBOOT images.

*ICER Compressor* ---
Image compression library written in Rust,
designed for deep-space communication.
Hand tuned for speed and portability by using only integer arithmetic,
no heap allocations, and no standard library by default.
Achieves practically instant compressions, even on microprocessors.

*Mirrorlist Generator* ---
Fetches Arch Linux package mirrors,
filtering them based on user parameters.
Sorts and outputs formatted data compliant with the pacman package manager.
Heavily outperforms default Python implementation.

== Education

#edu(
  institution: "Toronto Metropolitan University",
  dates: dates-helper(from: "Sep 2020", to: "Apr 2025"),
  location: "Canada",
  degree: "Bachelor's of Engineering, Computer Engineering",
)

- *Relevant Coursework*:
  Data Structures, FPGA Programming, Compilers & Interpreters, Digital Systems, Computer Networks
- *Extracurriculars*:
  Member of student robotics design team,
  teaching assistant for micro-processor courses.

== Skills

- *Languages*: #(
    "Rust",
    "Scheme",
    "Nix",
    "Haskell",
    "Erlang",
    "C++",
    "Lua",
    "TypeScript",
  ).join(", ")
- *Technologies*: #(
    "Linux",
    "Distributed Systems",
    "Compilers",
    "Virtualisation",
    "Infrastructure Automation",
    "Build Systems",
  ).join(", ")
