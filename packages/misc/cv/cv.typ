#set document(author: "Kleidi Bujari", title: "Kleidi's Resume!")
#set text(size: 10pt, lang: "en", ligatures: false)
#set page(margin: 1in, paper: "us-letter")

#show link: underline
#set par(justify: true)

#show heading.where(level: 1): it => [
  #set text(weight: 700, size: 20pt)
  #pad(it.body)
]

#show heading.where(level: 2): it => [
  #pad(top: 5pt, bottom: -10pt, [#smallcaps(it.body)])
  #line(length: 100%, stroke: 0.5pt)
]

#let generic-headline(
  left: "",
  right: "",
  description: "",
) = [#strong(left), #description #h(1fr) #right]

#let dates-helper(from: "", to: "") = from + " " + $dash.em$ + " " + to

#let edu(
  institution: "",
  dates: "",
  degree: "",
) = generic-headline(
  left: institution,
  description: degree,
  right: dates,
)

#let work(
  title: "",
  dates: "",
  company: "",
) = generic-headline(
  left: company,
  description: title,
  right: dates,
)

= Kleidi Bujari

#(
  link("mailto:mail@4kb.net"),
  link("https://github.com/kbujari")[github.com/kbujari],
  link("http://kleidi.ca")[kleidi.ca],
).join("  |  ")

== Experience

#work(
  company: "Meta",
  title: "Production Software Engineer",
  dates: dates-helper(from: "Aug 2025", to: "Present"),
)

- Analyzed Linux schedulers for Erlang/BEAM workloads,
  building kernel scheduler observability used across Meta.
- Led team designing scalable AWS/EKS infrastructure fighting internet censorship and poor network conditions.
- Built runtime type-checking for trillions of WhatsApp packets,
  solving entire class of account ID problems.
- Primary oncall for WhatsApp distributed system,
  improving reliability and mentoring engineers in debugging.

#work(
  company: "Toronto Metropolitan University",
  title: "Graduate Research Assistant",
  dates: dates-helper(from: "May 2024", to: "Sep 2024"),
)

- Organized webhosting and data analytics for a film release,
  with thousands of concurrent visitors.
- Built transformation pipeline for hundreds of media files,
  using unix primitives to parallelize workload.

#work(
  company: "Canadian Broadcasting Corporation",
  title: "Systems Engineering Intern",
  dates: dates-helper(from: "May 2023", to: "Apr 2024"),
)

- Built custom PXE-based provisioning for hundreds of devices on network,
  eliminating manual configuration.
- Architected VM cluster for 2024 Olympics handling all Canadian broadcasts,
  saving \$250k+ with reused hardware.

#work(
  company: "WSP Canada",
  title: "Student Engineer",
  dates: dates-helper(from: "May", to: "Aug") + ", 2021, 2022",
)

- Validated large scale electrical distribution for power consumption and cost efficiency.
- Extended internal databases with compression and deduplication,
  reclaiming terabytes of storage.

== Selected Projects

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

== Education

#edu(
  institution: "Toronto Metropolitan University",
  dates: dates-helper(from: "Sep 2020", to: "Apr 2025"),
  degree: "B. Eng, Computer Engineering",
)

- *Relevant Coursework*:
  Data Structures, FPGA Programming, Compilers, Computer Networks
- *Extracurriculars*:
  Student-led robotics design team,
  teaching assistant for micro-processor courses.

== Skills

- *Languages*: #(
    "Rust",
    "Haskell",
    "C++",
    "Erlang",
    "Nix",
    "Scheme",
  ).join(", ")
- *Technologies*: #(
    "Distributed Systems",
    "Compilers",
    "Virtualization",
    "Reproducible Builds",
  ).join(", ")
