"""Paper figures were originally created in PDF format.
Typst only supports SVG images at time of writing.
This script converts the PDFs to SVGs.
It uses the pdf2svg and svgo command line tools.
"""

# %%
import os
import subprocess
from glob import glob

from pdf_compressor import compress

dev_dir = os.path.expanduser("~/dev")
module_dir = os.path.dirname(__file__)

ffonons_in_dir = f"{dev_dir}/ffonons/figs/phonon-db"
ffonons_out_dir = f"{module_dir}/phonons"

mbd_in_dir = f"{dev_dir}/mbd/paper/figs"
mbd_out_dir = f"{module_dir}/mbd"

mace_mp_in_dir = f"{dev_dir}/thesis/tmp/mace-mp"
mace_mp_out_dir = f"{module_dir}/mace-mp"

compress_pdfs = True

file_io_map = {
    f"{dev_dir}/mace-mp-paper/figs/mp0v4compressed300dpi.pdf": f"{mace_mp_out_dir}/applications.svg",
    **{
        path: path.replace(".pdf", ".svg")
        for path in glob(f"{module_dir}/**/*.pdf", recursive=True)
    },
    **{
        path: f'{mbd_out_dir}/{os.path.basename(path).replace(".pdf", "-with-closed.svg")}'
        for path in glob(f"{mbd_in_dir}/**/metrics-table*.pdf", recursive=True)
        if "megnet" not in path
    },
    f"{dev_dir}/mace-mp-paper/figures_GNoME_materials/MACE_high_dens_relax.pdf": f"{mace_mp_out_dir}/parity-volume-gnome-mace-high-coordination.svg",
    f"{mace_mp_in_dir}/figures_tks/homonuclear-medium-periodic-table.pdf": f"{mace_mp_out_dir}/homonuclear-medium-periodic-table.svg",
    f"{mace_mp_in_dir}/figs/mace-mp-metrics.pdf": f"{mace_mp_out_dir}/mace-mp-train-val-curves.svg",
    f"{mace_mp_in_dir}/figs/mace-yuan-199-epoch-bulk-and-shear-moduli-latest-lowres.pdf": f"{mace_mp_out_dir}/bulk-and-shear-moduli.svg",
    f"{mace_mp_in_dir}/figures_materials_discovery/comb_mat_discover-lowres.pdf": f"{mace_mp_out_dir}/elem-sub-discovery.svg",
    f"{ffonons_in_dir}/ffonon-imag-clf-table-tol=0.01.pdf": f"{ffonons_out_dir}/ffonon-imag-clf-table-tol=0.01.svg",
    f"{ffonons_in_dir}/ffonon-metrics-table-tol=0.01.pdf": f"{ffonons_out_dir}/ffonon-metrics-table-tol=0.01.svg",
    **{
        path: f'{module_dir}/{os.path.basename(path).replace(".pdf", ".svg")}'
        for path in glob(
            f"{ffonons_in_dir}/**/phonons/*confusion-matrix.pdf", recursive=True
        )
    },
    f"{ffonons_in_dir}/parity-pbe-vs-ml-last-phdos-peak.pdf": f"{ffonons_out_dir}/parity-pbe-vs-ml-last-phdos-peak.svg",
    f"{mbd_in_dir}/scatter-largest-errors-models-mean-vs-true-hull-dist-all.pdf": f"{mbd_out_dir}/scatter-largest-errors-models-mean-vs-true-hull-dist-all.svg",
}

os.remove(f"{mbd_out_dir}/scatter-largest-errors-models-mean-vs-true-hull-dist-all.svg")

# subdict for which output files don't exist yet
file_io_map = {pdf: svg for pdf, svg in file_io_map.items() if not os.path.isfile(svg)}

for idx, (pdf, svg) in enumerate(file_io_map.items(), start=1):
    if not os.path.isfile(pdf):
        raise FileNotFoundError(f"{pdf} does not exist")
    print(f"{idx}: {pdf}: {svg}")


# %%
if compress_pdfs:
    compress(filenames=list(file_io_map), inplace=True)

for pdf, svg in file_io_map.items():
    # pdf2svg new_pdf new_svg
    subprocess.run(["pdf2svg", pdf, svg])

    # svgo compression
    subprocess.run(["svgo", svg, "--multipass"])
