using ModelicaScriptingTools: withOMC, testmodel
using Base.Filesystem
using Test

outdir = joinpath(@__DIR__, "../out")
modeldir = joinpath(@__DIR__, "..")
refdir = joinpath(@__DIR__, "../regRefData")

# create outdir and move working directory there to capture OMC outputs
if !ispath(outdir)
    mkdir(outdir)
end

withOMC(outdir, modeldir) do omc
    @testset "Simulate examples" begin
        @testset "HHmono" begin
            testmodel(omc, "HHmodelica.CompleteModels.HHmono"; refdir=refdir)
        end
        @testset "HHmodHier" begin
            testmodel(omc, "HHmodelica.CompleteModels.HHmodHier"; refdir=refdir)
        end
        @testset "HHmodular" begin
            testmodel(omc, "HHmodelica.CompleteModels.HHmodular"; refdir=refdir)
        end
        @testset "HHmodular1p" begin
            testmodel(omc, "HHmodelica.CompleteModels.HHmodular1p"; refdir=refdir)
        end
    end
end
