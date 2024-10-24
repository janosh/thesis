#let subfigure-kind = "subfigure"

#let subfigure-counter = counter(figure.where(kind: subfigure-kind))

#let subfigure(
  body,
  pos: bottom + center,
  dx: 0%,
  dy: 6%,
  caption: "",
  numbering: "(a)",
  separator: none,
  label: none,
  supplement: none,
  placement: top,
) = {
  subfigure-counter.step()

  let fig = figure(
    body,
    caption: none,
    kind: subfigure-kind,
    supplement: none,
    numbering: numbering,
    outlined: false,
    placement: placement,
  )

  if caption != "" and separator == none {
    separator = ":"
  }

  context {
    let sub-fig-num = subfigure-counter.display(numbering)
    let caption-content = [#supplement #sub-fig-num#separator #caption]
    return [#fig #label #place(pos, dx: dx, dy: dy, caption-content)]
  }
}

#let template(body) = {
  let body-font = "New Computer Modern"
  set page(margin: 25mm, numbering: "1", number-align: center)
  set text(font: body-font, size: 11pt, lang: "en")

  // equations: reference as "eq. (1)"
  set math.equation(numbering: "(1)", supplement: none)
  show ref: it => {
    // wrap equation numbers in parentheses when referencing
    if it.element != none and it.element.func() == math.equation {
      link(it.target)[eq.~(#it)]
    } else {
      it
    }
  }

  // dark blue links and references
  show ref: set text(fill: blue.darken(20%))
  show link: set text(fill: blue.darken(20%))

  // change sub/superscript font size
  set sub(size: 0.8em)
  set super(size: 0.8em)

  // headings
  show heading: set block(below: 1.3em, above: 2em) // increase space above and below headings
  // reference L1 headings as "chapters"
  show heading.where(level: 1): set heading(supplement: [Chapter])
  // style numbered L1 headings (only increase font size for unnumbered L1 headings)
  show heading: el => {
    // prefix first-level headings with "Chapter 1,2,..."
    set text(size: 1.3em) // increase font size
    if el != none and el.func() == heading and el.level == 1 {
      // only add "Chapter" prefix if the heading is numbered
      if el.numbering != none {
        [Chapter ]
        numbering(el.numbering, ..counter(heading).at(el.location()))
        v(5pt)
        block(el.body)
        v(15pt)
        return
      }
    }
    el
  }

  // style tables
  set table(
    inset: (x: 5pt, y: 4pt), // cell padding
    // blue shade for header row, light gray for first column
    fill: (col, row) => if row == 0 { blue.lighten(90%) } else if col == 0 { luma(245) } else { none },
    // thin horizontal lines between rows (except header), none between columns
    stroke: (_, y) => if y > 0 { (top: 0.2pt) },
  )
  // bold table headers
  show table.cell.where(y: 0): set text(weight: "bold")

  // paragraphs
  set par(leading: 1em)
  set par(justify: true, first-line-indent: 1em)
  show terms: set par(first-line-indent: 0pt)

  // figures
  show figure: set text(size: 0.95em)
  set figure(gap: 1em, placement: auto) // space between figure and caption

  show figure.caption: cap => {
    set par(leading: 0.85em) // reduce line height in captions
    if cap.position != top {
      // caption at figure bottom
      cap + v(11pt) // add vertical space after caption
    } else {
      // caption at figure top
      cap
    }
  }
  // move table captions above figure (default is below)
  // show figure.where(kind: table): set figure.caption(position: top)

  // make top-level ToC entries bold
  show outline.entry.where(level: 1): it => {
    set par(first-line-indent: 0pt)
    v(8pt)
    strong(it)
    v(-12pt)
  }


  // reset subfigure counter when out of the parent figure
  show figure: itm => {
    if itm.kind != subfigure-kind {
      subfigure-counter.update(0)
    }
    itm
  }
  show ref: itm => {
    let elem = itm.element
    // TODO if inside the subfigure's caption, directly reference the subfigure label without prefixing the figure counter
    if elem != none and elem.func() == figure and elem.kind == subfigure-kind {
      context {
        let qry = query(figure.where(outlined: true).before(itm.target)).last()
        if qry.has("label") {
          return ref(qry.label)
        }
      }
    }
    itm
  }

  body
}

#let title-page(
  title: "",
  degree: "",
  supervisor: "",
  advisors: (),
  examiners: (),
  author: "",
  submission-date: none,
  keywords: (),
  uni: "",
  college: "",
  department: "",
  logo: none,
) = {
  set document(title: title, author: author, keywords: keywords)
  set page(margin: (x: 30mm, y: 40mm), numbering: none)
  set text(font: "New Computer Modern Sans")
  set align(center)

  text(size: 2.2em, weight: 700, title)

  v(1cm)
  if logo != none {
    image(logo, width: 26%)
  }

  v(5mm)
  text(size: 1.5em, weight: 700, author)
  v(3mm)
  text(size: 1.5em, uni)
  linebreak()
  text(size: 1.5em, college)
  linebreak()
  text(size: 1.5em, department)

  v(15mm)

  text(size: 1.2em)[
    This dissertation is submitted for the degree of\
    Doctor of Philosophy
  ]
  v(2cm)

  set align(left)
  grid(
    columns: 2,
    gutter: 1em,
    [*Supervisors*], supervisor,
    [*Advisors*], advisors.join(", "),
    [*Examiners*], examiners.join(", "),
    [*Submission Date*], submission-date,
  )

  pagebreak()
}

#let remark(body, size: 9.5pt, length: 60%, stroke: .4pt, circle-radius: 1pt) = {
  // currently used for chapter-leading remarks like who led this work or where was it published
  set text(size: size)
  let start = (100% - length) / 2
  body
  v(3pt)
  line(start: (start, 0%), length: length, stroke: stroke)
  // add circles at both ends of the line
  place(circle(radius: circle-radius, fill: black), dx: start, dy: -circle-radius)
  place(circle(radius: circle-radius, fill: black), dx: start + length, dy: -circle-radius)
}

// paragraph heading (unnumbered by default)
#let par-heading(body, level: 4, numbering: none) = {
  set text(size: 0.8em)
  heading(numbering: numbering, level: level)[#body]
}

// order-of-magnitude
#let ord(num, base: 10) = $cal(O)(base^(num))$

#let mp-link(mp-id) = {
  let mp-details-url = "https://materialsproject.org/materials/"
  let id-pattern = regex("mp-\d+")

  if type(mp-id) == content and mp-id.text.find(id-pattern) != none {
    return link(mp-details-url + mp-id.text)[#mp-id]
  } else if type(mp-id) == str and mp-id.find(id-pattern) != none {
    return link(mp-details-url + mp-id)[#mp-id]
  } else if type(mp-id) == int and mp-id > 0 {
    let full-id = "mp-" + str(mp-id)
    return link(mp-details-url + full-id, full-id)
  } else {
    panic("Invalid mp-id=", mp-id)
  }
}

// shared this function with the community
// https://github.com/typst/typst/issues/1093#issuecomment-1881461639
#let num-fmt(num, decimal: ".", thousands: ",") = {
  // split the number into integer and decimal parts
  let parts = str(num).split(decimal)
  if parts.len() > 2 {
    panic("Invalid number contains more than 1 decimal: ", num)
  }
  // reverse the integer part to insert thousands separator
  let integer-part = parts
    .at(0)
    .rev()
    .clusters()
    .enumerate()
    .map(item => {
        let (idx, value) = item
        return value + if calc.rem(idx, 3) == 0 and idx != 0 {
          thousands
        }
      })
    .rev()
    .join("")
  // if the number has a decimal part, store it
  let decimal-part = if parts.len() == 2 {
    parts.at(1)
  }
  // return the formatted number
  return integer-part + if decimal-part != none {
    decimal + decimal-part
  }
}

// shared this function with the community
// https://github.com/typst/typst/issues/3269#issuecomment-2032612522
#let si-format(val, precision: 1, sep: "\u{202F}", binary: false, num-mode: "suffix") = {
  let factor = if binary {
    1024
  } else {
    1000
  }
  let gt1-suffixes = ("k", "M", "G", "T", "P", "E", "Z", "Y")
  let lt1-suffixes = ("m", "μ", "n", "p", "f", "a", "z", "y")
  let scale = ""
  let unit = ""
  let formatted = ""

  if type(val) == content {
    if val.has("text") {
      val = val.text
    } else if val.has("children") {
      val = val.children.map(content => content.text).join()
    } else {
      panic(val.children.map(content => content.text).join())
    }
  }
  // if val contains a unit, split it off
  if type(val) == str {
    unit = val.find(regex("(\D+)$"))
    val = float(val.split(unit).at(0))
  }

  if num-mode == "suffix" {
    if calc.abs(val) > 1 {
      for suffix in gt1-suffixes {
        if calc.abs(val) < factor {
          break
        }
        val /= factor
        scale += " " + suffix
      }
    } else if val != 0 and calc.abs(val) < 0.1 {
      for suffix in lt1-suffixes {
        if calc.abs(val) > 1 {
          break
        }
        val *= factor
        scale += " " + suffix
      }
    }

    formatted = str(calc.round(val, digits: precision))
  } else if num-mode == "format" {
    formatted = num-fmt(val)
  } else {
    panic("Invalid num-mode: ", num-mode)
  }

  formatted + sep + scale.split().at(-1, default: "") + unit
}

#let si0 = si-format.with(precision: 0)
#let si1 = si-format.with(precision: 1)
#let si4 = si-format.with(precision: 4)
#let percent(val, supplement: "%", precision: 1) = (
  si-format(
    val * 100,
    precision: precision,
  ) + supplement
)
