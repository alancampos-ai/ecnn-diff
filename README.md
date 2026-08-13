# ecnn-diff

#### Article:   <small><strong>Equivariant dissipative generators for differential systems}</strong>  <a href="https://doi.org/10.1016/j.cam.2026.117584"><img src="https://cdn.simpleicons.org/doi/2dd4bf" alt="DOI" height="14" align="absmiddle"></a>  <a href="https://doi.org/10.1016/j.cam.2026.117584"><img src="https://cdn.simpleicons.org/zenodo/2dd4bf" alt="Zenodo" height="14" align="absmiddle"></a>  <a href="https://drive.google.com/drive/folders/1DPsSIUbaE4k2ttw2Wi_G0KwfF2cu6Tqm?usp=sharing"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg" alt="Google Drive" height="14" align="absmiddle"></a></small>

Experiments on spherical kernel spaces evaluate stable weighted sampling and reconstruction for scalar and equivariant feature fields on the sphere. The implementation supports full cardinal, approximate local Lagrange, kernel-translate, spherical-harmonic, Tikhonov, and reduced-harmonic moving least-squares reconstructions. Equivariant experiments use Levi-Civita parallel transport with SO(2) representation orders m=0,1,2,3. The supplied profiles include multiple center sizes, sampling ratios, spherical point-set families, and random seeds. Numerical quality is assessed using Marcinkiewicz-Zygmund spectral bounds, reconstruction error, conditioning, noise amplification, convergence, localization, and Hölder diagnostics. The equivariant implementation also evaluates gauge covariance, co-rotated SO(3) covariance, fixed-grid equivariance error, and transfer across Fibonacci, icosphere, and equirectangular grids. The experiments additionally record computational time and memory complexity, enabling quantitative analysis of stability, accuracy, equivariance, and cost.

#### Dependencies

* Python >= 3.8
* numpy
* scipy
* matplotlib

#### Bash

```bash
pip install numpy scipy matplotlib
```

#### License (MIT)

* Copyright (c) alancampos-ai
* Code released under the MIT License.
