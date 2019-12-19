using OMJulia
using Base.Filesystem
using Test

moroot = dirname(@__DIR__)
outdir = "out"
cd(moroot)
if !ispath(outdir)
    mkdir(outdir)
end
cd(outdir)

omc = OMJulia.OMCSession()
try
    mopath = OMJulia.sendExpression(omc, "getModelicaPath()")
    mopath = "$mopath:$(escape_string(moroot))"
    println("Setting MODELICAPATH to ", mopath)
    OMJulia.sendExpression(omc, "setModelicaPath(\"$mopath\")")
    # load Modelica standard library
    OMJulia.sendExpression(omc, "loadModel(Modelica)")
    @testset "Simulate examples" begin
        @testset "HHmono" begin
            r = OMJulia.sendExpression(omc, "loadModel(HHmodelica.CompleteModels.HHmono)")
            @test r
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
            r = OMJulia.sendExpression(omc, "simulate(HHmodelica.CompleteModels.HHmono, stopTime=30, numberOfIntervals=3000, outputFormat=\"csv\")")
            println(r["messages"])
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
        end
        @testset "HHmodFlat" begin
            r = OMJulia.sendExpression(omc, "loadModel(HHmodelica.CompleteModels.HHmodFlat)")
            @test r
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
            r = OMJulia.sendExpression(omc, "simulate(HHmodelica.CompleteModels.HHmodFlat, stopTime=0.03, numberOfIntervals=3000, outputFormat=\"csv\")")
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
        end
        @testset "HHmodular" begin
            r = OMJulia.sendExpression(omc, "loadModel(HHmodelica.CompleteModels.HHmodular)")
            @test r
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
            r = OMJulia.sendExpression(omc, "simulate(HHmodelica.CompleteModels.HHmodular, stopTime=0.03, numberOfIntervals=3000, outputFormat=\"csv\")")
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
        end
        @testset "HHmodular1p" begin
            r = OMJulia.sendExpression(omc, "loadModel(HHmodelica.CompleteModels.HHmodular1p)")
            @test r
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
            r = OMJulia.sendExpression(omc, "simulate(HHmodelica.CompleteModels.HHmodular1p, stopTime=0.03, numberOfIntervals=3000, outputFormat=\"csv\")")
            es = OMJulia.sendExpression(omc, "getErrorString()")
            @test es == ""
        end
    end
finally
    println("Closing OMC session")
    sleep(1)
    OMJulia.sendExpression(omc, "quit()", parsed=false)
    println("Done")
end
