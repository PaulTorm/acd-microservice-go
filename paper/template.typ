#let template(
  title: [Paper Title],
  authors: (),
  abstract: none,
  bibliography: none,
  body
) = {
  set document(title: title, author: authors.map(author => author.name))

  set text(font: "TeX Gyre Termes", size: 10pt, lang: "de")
  set heading(numbering: "1.")
  set page(numbering: "1")

  place(
    top,
    float: true,
    scope: "parent",
    clearance: 30pt,
    {
      v(3pt, weak: true)
      align(center, par(leading: 0.5em, text(size: 24pt, title)))
      v(8.35mm, weak: true)

      set par(leading: 0.6em)
      for i in range(calc.ceil(authors.len() / 3)) {
        let end = calc.min((i + 1) * 3, authors.len())
        let is-last = authors.len() == end
        let slice = authors.slice(i * 3, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: 12pt,
          ..slice.map(author => align(center, {
            text(size: 11pt, author.name)
            if "organization" in author [
              \ #emph(author.organization)
            ]
            if "email" in author {
              if type(author.email) == str [
                \ #link("mailto:" + author.email)
              ] else [
                \ #author.email
              ]
            }
          }))
        )

        if not is-last {
          v(16pt, weak: true)
        }
      }
    }
  )

  outline()

  if abstract != none [
    #set text(9pt, weight: 700, spacing: 150%)
    _Abstract_---#h(weak: true, 0pt)#abstract
  ]

  body
}

