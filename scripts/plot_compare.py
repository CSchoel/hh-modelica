import pandas as pd
import matplotlib.pyplot as plt
import os


def compare(afile, bfile):
    adata, bdata = [pd.read_csv(x, delimiter=",") for x in [afile, bfile]]
    f = plt.figure(figsize=(6,2))
    ax = f.add_subplot()
    ax.plot(adata["time"] * 1000, adata["currentClamp.v"], label="modular")
    ax.plot(bdata["time"], bdata["v"], "--", label="monolithic")
    ax.set_xlabel("time [ms]")
    ax.set_ylabel("voltage [mV]")
    ax.legend(loc="best")
    f.tight_layout()
    if not os.path.exists("plots"):
        os.mkdir("plots")
    f.savefig("plots/modular_vs_monolithic.pdf")
    f.savefig("plots/modular_vs_monolithic.png")

if __name__ == "__main__":
    compare(
        "out/HHmodelica.CompleteModels.HHmodFlat_res.csv",
        "out/HHmodelica.CompleteModels.HHmono_res.csv"
    )
