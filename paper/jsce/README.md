# JSCE Manuscript Workspace

This directory contains the working files for the JSCE manuscript based on the SLSC project.

## Files

- `main.tex`: manuscript entry point
- `sections/`: section drafts
- `fig/`: manuscript figures
- `jjsce.cls`: JSCE class file
- `jjsce-macros.sty`: helper macros for figure/table references

## Build

Open the repository root in VS Code and edit `paper/jsce/main.tex`.
With LaTeX Workshop installed, save the file to build automatically via `latexmk + lualatex`.

Generated files are written to `paper/jsce/out/`.
