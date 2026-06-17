#let subfigure-kind = "subfigure"

// Find the nearest preceding non-subfigure to scope sibling lookups.
#let subfigure-parent(loc) = query(selector(figure).before(loc)).filter(fig => fig.kind != subfigure-kind).last()

#let subfigure(
  body,
  pos: bottom + center,
  dx: 0%,
  dy: 6%,
  caption: "",
  numbering: "a)",
  label: none,
  supplement: none,
  placement: top,
) = {
  let fig = figure(
    body,
    caption: none,
    kind: subfigure-kind,
    supplement: none,
    numbering: numbering,
    outlined: false,
    placement: placement,
  )

  context {
    // Letter index = number of preceding subfigures sharing the same parent.
    let parent = subfigure-parent(here())
    let preceding = query(figure.where(kind: subfigure-kind).within(parent.location()).before(here()))
    let sub-fig-num = std.numbering(numbering, preceding.len() + 1)
    let caption-content = [#supplement #sub-fig-num #caption]
    [ #fig#label #place(pos, dx: dx, dy: dy, caption-content) ]
  }
}

#let template(body) = {
  set page(margin: 25mm, numbering: "1", number-align: center)
  set text(font: "New Computer Modern", size: 11pt, lang: "en")

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
    set text(size: 1.3em) // increase font size
    // prefix numbered first-level headings with "Chapter 1,2,..."
    if el.level == 1 and el.numbering != none {
      [Chapter ]
      numbering(el.numbering, ..counter(heading).at(el.location()))
      v(5pt)
      block(el.body)
      v(15pt)
    } else {
      el
    }
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
  set par(leading: 1em, justify: true, first-line-indent: 1em)
  show terms: set par(first-line-indent: 0pt) // Reset indent for definition lists

  // figures
  show figure: set text(size: 0.95em)
  set figure(gap: 1em, placement: auto) // space between figure and caption

  show figure.caption: cap => {
    set par(leading: 0.85em) // reduce line height in captions
    if cap.position == top { cap } else { cap + v(11pt) }
  }
  // move table captions above figure (default is below)
  // show figure.where(kind: table): set figure.caption(position: top)

  // make top-level ToC entries bold and adjust spacing
  show outline.entry.where(level: 1): it => [#v(1em)#strong(it)]

  // Custom rule for formatting references to subfigures as "Figure 1a)"
  show ref: itm => {
    let elem = itm.element
    if elem != none and elem.func() == figure and elem.kind == subfigure-kind {
      let parent = subfigure-parent(elem.location())
      let parent-num = counter(figure.where(kind: parent.kind)).at(parent.location()).first()
      let siblings = query(figure.where(kind: subfigure-kind).within(parent.location()))
      let subfig-num = numbering(elem.numbering, siblings.position(sub => sub.location() == elem.location()) + 1)
      return [#parent.supplement #parent-num#subfig-num]
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
  set text(font: "libertinus serif")
  set align(center)

  text(size: 2.2em, weight: 700, title)

  v(1cm)
  if logo != none { image(logo, width: 26%) }

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
  let id = if type(mp-id) == content { mp-id.text } else { mp-id }

  if type(id) == str and id.find(regex("mp-\d+")) != none {
    link(mp-details-url + id, mp-id)
  } else if type(id) == int and id > 0 {
    let full-id = "mp-" + str(id)
    link(mp-details-url + full-id, full-id)
  } else {
    panic("Invalid mp-id=", mp-id)
  }
}

// shared this function with the community
// https://github.com/typst/typst/issues/1093#issuecomment-1881461639
#let num-fmt(num, decimal: ".", thousands: ",") = {
  let parts = str(num).split(decimal)
  if parts.len() > 2 {
    panic("Invalid number contains more than 1 decimal: ", num)
  }
  let integer-part = parts.first().rev().clusters().enumerate().map(item => {
    let (idx, value) = item
    value + if calc.rem(idx, 3) == 0 and idx != 0 { thousands }
  }).rev().join("")
  let decimal-part = parts.at(1, default: none)
  integer-part + if decimal-part != none { decimal + decimal-part }
}

#let si-format(val, precision: 1, sep: "\u{202F}", binary: false, num-mode: "suffix") = {
  let factor = if binary { 1024 } else { 1000 }
  let gt1-suffixes = ("k", "M", "G", "T", "P", "E", "Z", "Y")
  let lt1-suffixes = ("m", "μ", "n", "p", "f", "a", "z", "y")
  let scale = ""
  let unit = ""

  if type(val) == content {
    val = if val.has("text") {
      val.text
    } else if val.has("children") {
      val.children.map(child => child.text).join()
    } else {
      panic("si-format: cannot extract text from " + repr(val))
    }
  }
  // if val contains a unit, split it off
  if type(val) == str {
    unit = val.find(regex("(\D+)$"))
    val = float(val.split(unit).at(0))
  }

  let formatted = if num-mode == "suffix" {
    let scaling = if calc.abs(val) > 1 {
      (gt1-suffixes, value => value >= factor, value => value / factor)
    } else if val != 0 and calc.abs(val) < 0.1 {
      (lt1-suffixes, value => value <= 1, value => value * factor)
    }
    if scaling != none {
      let (suffixes, should-scale, scale-value) = scaling
      for suffix in suffixes {
        if not should-scale(calc.abs(val)) { break }
        val = scale-value(val)
        scale = suffix
      }
    }
    str(calc.round(val, digits: precision))
  } else if num-mode == "format" {
    num-fmt(val)
  } else {
    panic("Invalid num-mode: ", num-mode)
  }
  formatted + sep + scale + unit
}

#let si0 = si-format.with(precision: 0)
#let si1 = si-format.with(precision: 1)
#let si4 = si-format.with(precision: 4)
#let percent(val, supplement: "%", precision: 1) = (
  si-format(val * 100, precision: precision) + supplement
)
