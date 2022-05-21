# About FTDMP

FTDMP is a software system for running docking experiments and scoring/ranking multimeric models.

FTDMP has two main entry-point scripts:

* "ftdmp-all" - script to perform docking and scoring/ranking.
* "ftdmp-qa-all" - script to perform scoring/ranking only.

FTDMP uses several software tools that are included in the FTDMP package:

* "voronota-js"
* "voronota-iface-gnn" (inter-chain interface scoring tool based on graph neural networks)
* "ftdock" (a modified version of a popular rigid-body-docking software tool), it depends on "fftw-2.1.5" that is also included
* "FASPR" (a fast tool for rebuilding sidechains in protein structures)

FTDMP also can use non-open-source docking tools that are not included in the FTDMP package, but can be easily installed separately:

* "HEX" (a rigid-body-docking software tool)
* "SAM" (a symmetry-docking software tool)

Some features of FTDMP require aditional dependencies (that are easily available through "conda" package manager):

 * graph neural network-based scoring using "voronota-iface-gnn" requires "R", "PyTorch" and "PyTorch Geometric"
 * relaxing using molecular dynamics requires "OpenMM"

# Obtaining and installing FTDMP

## Getting the latest version

The currently recommended way to obtain FTDMP is cloning the FTDMP git repository:

    git clone https://github.com/kliment-olechnovic/ftdmp.git
    cd ./ftdmp

## Building the included software

To build all the included dependencies, run the following command:

    ./core/build.bash

## Installing

To, optionally, make FTDMP accessible without specifying full path, add the following line at the end of ".bash_profile" or ".bashrc":

    export PATH="/path/to/ftdmp:${PATH}"

## Setting Miniconda for using graph neural network-based scoring

Download the Miniconda package:

	cd ~/Downloads
	wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh
	
Install Miniconda:

    bash ./Miniconda3-py39_4.11.0-Linux-x86_64.sh
    
Activate Miniconda environment an install packages:

    source ~/miniconda3/bin/activate
    
    conda install r # may skip this if you have R already and do not want it in Miniconda
    
    conda install pytorch -c pytorch
    conda install pyg -c pyg


# Using FTDMP

## Scoring and ranking multimeric models using all available scoring tools

Example of scoring with rebuilding side-chains:

    ls ./*.pdb | ftdmp-qa-all --conda-path ~/miniconda3 --workdir './tmp/works' --rank-names extended_for_protein_protein
    
Example of scoring without rebuilding side-chains:

    ls ./*.pdb | ftdmp-qa-all --conda-path ~/miniconda3 --workdir './tmp/works' --rank-names extended_for_protein_protein_no_sr

## Scoring and ranking multimeric models without using graph neural networks

Example of scoring with rebuilding side-chains:

    ls ./*.pdb | ftdmp-qa-all --workdir './tmp/works' --rank-names standard_for_protein_protein
    
Example of scoring without rebuilding side-chains:

    ls ./*.pdb | ftdmp-qa-all --workdir './tmp/works' --rank-names standard_for_protein_protein_no_sr

