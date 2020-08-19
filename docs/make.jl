using Documenter
using ModelicaScriptingTools

makedocs(
    sitename = "HH-Modelica",
    format = Documenter.HTML(),
    modules = Module[]
)

deploydocs(
    repo = "github.com/CSchoel/hh-modelica.git",
    versions = ["v^", "v#.#", "stable" => "v^"]
)
