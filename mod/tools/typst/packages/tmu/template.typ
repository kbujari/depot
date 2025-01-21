#let report(
  title: [],
  course: [],
  semester: [],
  authors: (),
  doc,
) = {
  set page(
    paper: "us-letter",
    margin: 1.5in,
    numbering: "1",
    header: align(horizon, strong(course + h(1fr) + semester)),
  )

  set align(center)
  text(18pt, strong(title))
  linebreak()
  text(12pt, "Toronto Metropolitan University")

  v(24pt)

  grid(
    columns: (1fr,) * calc.min(authors.len(), 4),
    row-gutter: 12pt,
    ..authors.map(a => [
      #a.name \
      #a.id \
      #link("mailto:" + a.email)
    ])
  )

  set align(left)
  set par(justify: true)
  v(24pt)

  doc
}
