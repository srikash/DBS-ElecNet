# DBS-ElecNet
### A method for automated localization and segmentation of DBS electrodes in clinical MRI
Vanessa H. Yu, Edward Chen, Jürgen Germann, Alexandre Boutet, Andres M. Lozano, Kâmil Uludağ, and Sriranga Kashyap

*V. H. Yu et al., "DBS-ElecNet: Automated Localization and Segmentation of DBS Electrodes in Clinical MRI," 2026 IEEE 23rd International Symposium on Biomedical Imaging (ISBI), London, United Kingdom, 2026, pp. 1-4, doi:[10.1109/ISBI61048.2026.11515562](https://doi.org/10.1109/ISBI61048.2026.11515562)*

Poster available at: [https://zenodo.org/records/19430997](https://zenodo.org/records/19430997)

## Table of Contents
<!-- 1. [Data Preprocessing](#data-preprocessing) -->
1. [Requirements](#requirements)
2. [SALINE Electrode Segmentation](#SALINE-electrode-segmentation)
3. [DBS-ElecNet Inference](#DBS-ElecNet-Inference)

## Requirements

### Python

- Python 3.12+ (raised by SALINE's own requirement)
- Install Python dependencies:

```bash
python3 -m pip install -r requirements.txt
```

This also installs [SALINE](https://github.com/srikash/SALINE) and its `saline` CLI, which `run_saline` calls.

### External command-line tools

**ANTs** (`ResampleImage`, `N4BiasFieldCorrection`, `ImageMath`) must be on your `PATH`.

Skull-stripping (SynthStrip) and segmentation (SynthSeg) run via **Docker** by
default — no local FreeSurfer install needed:

- [`freesurfer/synthstrip`](https://hub.docker.com/r/freesurfer/synthstrip)
- [`cookpa/synthseg`](https://hub.docker.com/r/cookpa/synthseg)

`run_saline` and `run_elecnet` check for Docker automatically. If it isn't
available, pass precomputed files instead with `--brain_mask PATH` (both
scripts) and `--synthseg PATH` (`run_saline` only) — these must already be in
the same 1mm-isotropic space as `subject_1mm_iso.nii.gz`, i.e. produced from
that resampled file, not the original native-space input.

## SALINE electrode segmentation:

This pipeline performs single- or dual-electrode localization using the SALINE framework.

**Command:**
```bash
./run_saline <nifti_file> <num_elec> [--brain_mask PATH] [--synthseg PATH]
```
**Required arguments:**

* `nifti_file`: Path to the input MRI volume (NIfTI format).

* `num_elec`: Number of implanted electrodes (1 or 2).

**Optional arguments:**

* `--brain_mask`: precomputed brain mask, skips Docker-based SynthStrip.
* `--synthseg`: precomputed SynthSeg segmentation, skips Docker-based SynthSeg.

**Output:**

* `subject_saline_elec.nii.gz`: Electrode segmentation in the native image space.

* `subject_1mm_iso.nii.gz`: Input MRI resampled to 1 mm isotropic resolution.

* `subject_1mm_iso_saline_elec.nii.gz`: Electrode segmentation in 1 mm isotropic space.


## DBS-ElecNet Inference:

This pipeline performs electrode segmentation using DBS-ElecNet.

**Command:**
```bash 
./run_elecnet <nifti_file> <device> [--brain_mask PATH]
```
**Required arguments:**

* `nifti_file`: Path to the input MRI volume (NIfTI format).

* `device`: Inference device, following PyTorch conventions (cpu, cuda, cuda:0, etc.).

**Optional arguments:**

* `--brain_mask`: precomputed brain mask, skips Docker-based SynthStrip.

**Output:**

* `subject_elec.nii.gz`: Electrode segmentation in the native image space.

* `subject_1mm_iso.nii.gz`: Input MRI resampled to 1 mm isotropic resolution.

* `subject_1mm_iso_elec.nii.gz`: Electrode segmentation in 1 mm isotropic space.

## Note:

- All preprocessing steps are performed automatically, including resampling to 1 mm isotropic resolution, skull stripping (Docker), N4 bias field correction, and (for SALINE) SynthSeg (Docker).  
- Intermediate files are removed upon completion **except for the 1 mm isotropic resampled MRI** (`subject_1mm_iso.nii.gz`), which is retained for reference.  
- Final outputs are provided in **both 1 mm isotropic space and the original native image space**.
