#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#let vector(v) = $bold(#v)$
#let legend-box = (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt)
#let style-axes() = {
  let axis(label) = {
    let style = (:)
    if label != none { style.label = label }
    style.mark = (end: "stealth", fill: black)
    style
  }
  draw.set-style(axes: (x: axis(none), y: axis((anchor: "north-west", offset: -0.2))))
}
#let series-colors = (
  (rgb("#0B5FA5"), none),
  (rgb("#C2570A"), none),
  (rgb("#12793F"), none),
  (rgb("#A81E7A"), none),
  (rgb("#7A3E9D"), "dashed"),
  (rgb("#C0182B"), "densely-dotted"),
)
#let series(idx, thickness: 1.5pt) = {
  let (paint, dash) = series-colors.at(calc.rem(idx, series-colors.len()))
  (paint: paint, dash: dash, thickness: thickness)
}

#let relu(x) = if x < 0 { 0 } else { x }
#let gelu(x) = (
  0.5 * x * (1 + calc.tanh(calc.sqrt(2 / calc.pi) * (x + 0.044715 * calc.pow(x, 3))))
)
#let leaky-relu(x) = calc.max(0.05 * x, x)
#let sigmoid(x) = 1 / (1 + calc.exp(-x))
#let tanh(x) = (calc.exp(x) - calc.exp(-x)) / (calc.exp(x) + calc.exp(-x))

#canvas({
  style-axes()
  plot.plot(
    size: (8, 5),
    y-tick-step: 1,
    x-tick-step: 2,
    legend: "inner-north-west",
    legend-style: legend-box,
    axis-style: "left",
    x-grid: true,
    y-grid: true,
    {
      let curves = (
        "ReLU": relu,
        "GELU": gelu,
        "Leaky ReLU": leaky-relu,
        "Sigmoid": sigmoid,
        "Tanh": tanh,
      )
      for (idx, (key, func)) in curves.pairs().enumerate() {
        plot.add(style: (stroke: series(idx)), domain: (-4, 4), func, label: key)
      }
    },
  )
})

// #box(width: 30em)[
//   Popular ML activation functions.
//   $"ReLU"(vector(x)) = vector(x)^+ = max(vector(x), 0)$ is the most widely used activation function in deep learning due to its simplicity and computational efficiency.
//   $"GELU"(vector(x), mu=0, sigma=1) = vector(x) / 2 (1 + op("erf") (vector(x) \/ sqrt(2)))$ is a differentiable variant of ReLU.
//   $"Leaky ReLU"(vector(x)) = max(0, vector(x)) + alpha dot min(0, vector(x))$ with $alpha < 0$ is a variant of ReLU that adds a small gradient for negative activations.
//   $"Sigmoid"(vector(x)) = (1 + exp(-vector(x)))^(-1)$ smoothly squashes the input to the range (0, 1).
//   $"Tanh"(vector(x)) = (exp(vector(x))+exp(vector(−x))) / (vector(exp(x))−exp(vector(−x)))$ is a scaled and shifted version of the sigmoid function.
// ]
