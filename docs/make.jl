using Documenter
using ModelicaScriptingTools

makedocs(
    sitename = "HH-Modelica",
    format = Documenter.HTML(),
    modules = Module[]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
