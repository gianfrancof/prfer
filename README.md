
# pRFer

This is the repository for the _fMRI bootcamp_ of the [*Summer School in Sensory Neuroscience 2025*](https://www.unipi.it/wp-content/uploads/SWS_Binda_2025_Poster.pdf) organized by [University of Pisa](https://www.unipi.it) and [Science of Intelligence](https://www.scienceofintelligence.de/) with the support of [Circle U.](https://www.circle-u.eu/) initiative [NEUROBRIDGE](https://www.sns.it/en/tne-neurobridge-initiatives). 

---

## Overview

- Implements the fundamental tools for _population Receptive Field_[(pRF)](https://www.sciencedirect.com/science/article/abs/pii/S1053811907008269?via%3Dihub) modeling in MATLAB
- Requires `fminsearchbnd.m` (included in this repo) by John D'Errico for optimization (see [Matlab Central File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon) and MATLAB Optimization Toolbox
- Includes basic plotting functions

---

## Installation & Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/gianfrancof/prfer.git
   cd prfer

2. Open MATLAB and run `prf_tutorial.m`

---

## Citation

Data and code provided in this repository have been used [here](https://www.nature.com/articles/s41467-024-54336-5)

If you use this code, please cite it as: 

```bibtex
@article{Centanino2024,
	author = {Centanino, Valeria and Fortunato, Gianfranco and Bueti, Domenica},
	title = {{The neural link between stimulus duration and spatial location in the human visual hierarchy}},
	journal = {Nat. Commun.},
	volume = {15},
	number = {10720},
	pages = {1--19},
	year = {2024},
	month = dec,
	issn = {2041-1723},
	publisher = {Nature Publishing Group},
	doi = {10.1038/s41467-024-54336-5}
}
```

---

## License

This project is distributed under the MIT License. This means you are free to use, modify, and distribute the code, provided that the original license and copyright notice are included in any copies or substantial portions of the software. See the [LICENSE](LICENSE) file for the full text.
