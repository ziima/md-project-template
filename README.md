# md-project-template

This project contains a template for molecular dynamics project, most commonly in NAMD.

## Project structure ##
The configuration of the project is hierachical.

The project basic configuration in the pro project root, namely files [environment.tcl](project/environment.tcl), [runner.tcl](project/runner.tcl) and force field parameters.
The environment file contains a basic setup for the simulation environment.
The runner file performs the simulations based on the phase in effect.

Second level is the simulations.
They contain a simulation specific configuration in file [namd.tcl](project/simulation/namd.tcl).

Third level is the individual runs.
An example contain basic phases: minimization, warm, equilibration and production run.
Their specific configuration is in the run configuration fiels, such as [00_minimize.namd](project/simulation/00_minimize/00_minimize.namd).

## Usage ##
Copy the project directory and modify to your specific needs.
The configuration files are designed to be run from the run directories, e.g.

    cd project/simulation/00_minimize
    namd2 00_minimize.namd > 00_minimize.output 2> 00_minimize.error
