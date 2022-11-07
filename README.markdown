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


# Using FTDMP for scoring and ranking multimeric models

## Scoring and ranking multimeric protein models using all available scoring tools

Example of scoring with rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names extended_for_protein_protein \
      --conda-path ~/miniconda3 \
      --workdir './works'
    
Example of scoring without rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names extended_for_protein_protein_no_sr \
      --conda-path ~/miniconda3 \
      --workdir './works'

## Scoring and ranking multimeric protein models without using graph neural networks

Example of scoring with rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names standard_for_protein_protein \
      --workdir './works'
    
Example of scoring without rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names standard_for_protein_protein_no_sr \
      --workdir './works'

## Scoring and ranking multimeric models that include RNA or DNA:

Example of scoring with rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names standard_for_generic \
      --workdir './works'


# Using FTDMP for docking

## Command line user interface

Docking and scoring is done with the 'ftdmp-all' script.
Below is the breef description of 'ftdmp-all' interface.

    'ftdmp-all' docks, scores and ranks complex structures of proteins or nucleic acids
    
    Options:
        --job-name                string  *  job name
        --pre-docked-input-dir    string     pre-docked input directory path 
        --static-file             string     hetero docking static input file path
        --static-sel              string     hetero docking query to restrict static atoms, default is '[]'
        --static-chain            string     hetero docking chain name or chain renaming rule to apply for static atoms, default is ''
        --mobile-file             string     hetero or homo docking mobile input file path
        --mobile-sel              string     hetero or homo docking query to restrict mobile atoms, default is '[]'
        --mobile-chain            string     hetero or homo docking chain name or chain renaming rule to apply for mobile atoms, default is ''
        --symmetry-docking        string     homo docking symmetry to apply for the mobile input file, default is ''
        --subselect-contacts      string     query to subselect inter-chain contacts for scoring, default is '[]'
        --constraints-required    string     query to check required inter-chain contacts, default is ''
        --constraints-banned      string     query to check banned inter-chain contacts, default is ''
        --constraint-clashes      number     max allowed clash score, default is ''
        --reference               string     input structure file to compute CAD-score with, default is ''
        --openmm-forcefield       string     forcefield name for OpenMM-based operations, default is ''
        --ftdmp-root              string     ftdmp root path, default is '' (autodetected from the calling command)
        --conda-path              string     conda installation path, default is ''
        --conda-early             string     flag to activate conda as early as possible
        --conda-env               string     conda main environment name, default is ''
        --conda-env-for-gnn       string     conda GNN environment name, equals the main environment name if not set
        --sam-parameters          string     additional SAM parameters, default is '-top=8000 -show=2000 -clusters=2000'
        --use-ftdock              string     flag to use ftdock, default is 'true'
        --use-hex                 string     flag to use HEX, default is 'false'
        --ftdock-keep             number     ftdock keep parameter, default is 1
        --ftdock-angle-step       number     ftdock angle step parameter, default is 9
        --ftdock-min-grid-sep     number     minimum grid separation between same-rotation translations, default is 20
        --hex-macro-mode          string     flag to enable HEX macro mode, default is 'true'
        --hex-max-solutions       number     max number of docking solutions for HEX, default is 10000
        --hex-script              string     semicolon-sparated additional commands for HEX, default is ''
        --hex-swap-and-repeat     string     flag to run HEX twice with monomers swapped, default is 'false'
        --parallel-docking        number     number of processes to run when docking, default is 8
        --parallel-scoring        number     number of processes to run when scoring, default is 8
        --cache-dir               string     cache directory path to store results of past slower calculations
        --sbatch-for-ftdock       string     sbatch parameters to run docking with ftdock in parallel, default is ''
        --sbatch-for-hex-or-sam   string     sbatch parameters to run docking with HEX or SAM on cluster, default is ''
        --sbatch-scoring          string     sbatch parameters to run scoring in parallel, default is ''
        --score-symmetry          string     flag to score symmetry, default is 'false'
        --local-columns           string     flag to add per-residue scores to the global output table, default is 'false'
        --remap-cadscore          string     flag to use optimal chains remapping for CAD-score, default is 'false'
        --scoring-full-top        number     number of top complexes to keep after full scoring stage, default is 1000
        --scoring-full-top-slow   number     number of top complexes to keep before slow full scoring stage, default is 300
        --scoring-rank-names      string  *  rank names to use, or name of a standard set of rank names
        --scoring-ranks-top       number     number of top complexes to consider for each ranking, default is 100
        --scoring-jury-slices     string     slice sizes sequence definition for ranks jury scoring, default is '10 50'
        --scoring-jury-cluster    number     clustering threshold for ranks jury scoring, default is 0.9
        --scoring-jury-maxs       number     number of max values to use for ranks jury scoring, default is 5
        --redundancy-threshold    number     minimal ordered redundancy value to accept, default is 1
        --build-complexes         number     number of top complexes to build, default is 0
        --multiply-chains         string     options to multiply chains, default is ''
        --relax-complexes         string     options to relax complexes, default is ''
        --only-dock-and-score     string     flag to only dock, score and quit after scoring, default is 'false'
        --diversify               number     step of CAD-score to diversify scoring results and exit, default is ''
        --plot-jury-scores        string     flag to output plot of jury scores, default is 'false'
        --casp15-qa               string     flag to output CASP15 QA answer, default is 'false'
        --casp15-qa-target        string     target name for outputting CASP15 QA answer, default is '_THETARGET_'
        --casp15-qa-author-id     string     author ID for outputting CASP15 QA answer, default is '_THEAUTHOR_'
        --output-dir              string  *  output directory path
        --help | -h                          flag to display help message and exit
        
    Examples:
        
        ftdmp-all --job-name 'j1' --static-file './chainA.pdb' --mobile-file './chainB.pdb' \
        --scoring-rank-names 'standard_for_protein_protein' --output-dir './results'
        
        ftdmp-all --job-name 'j2' --pre-docked-input-dir './predocked' \
        --scoring-rank-names 'standard_for_protein_protein' --output-dir './results'

## Example of protein-protein docking for running on cluster

    #!/bin/bash
    
    STATICFILE="./input/bigger_molecule.pdb"
    MOBILEFILE="./input/smaller_molecule.pdb"
    JOBNAME="$(basename ${STATICFILE} .pdb)__$(basename ${MOBILEFILE} .pdb)"
    
    sbatch --job-name=rdwf --partition=Cluster --ntasks=1 --cpus-per-task=1 --mem-per-cpu=4000 \
    ${HOME}/git/ftdmp/ftdmp-all \
      --ftdmp-root ${HOME}/git/ftdmp \
      --conda-path ${HOME}/miniconda3 \
      --conda-early 'true' \
      --parallel-docking 64 \
      --parallel-scoring 128 \
      --sbatch-for-ftdock '--job-name=ftdock --partition=Cluster --ntasks=1 --cpus-per-task=1 --mem-per-cpu=8000' \
      --sbatch-for-hex-or-sam '--job-name=hexsam --partition=Cluster --ntasks=1 --cpus-per-task=8 --mem-per-cpu=8000' \
      --sbatch-scoring '--job-name=dscore --partition=Cluster --ntasks=1 --cpus-per-task=1 --mem-per-cpu=8000' \
      --openmm-forcefield '' \
      --relax-complexes '' \
      --job-name "$JOBNAME" \
      --output-dir ./output \
      --static-file "$STATICFILE" \
      --static-sel '[]' \
      --mobile-file "$MOBILEFILE" \
      --mobile-chain 'C' \
      --mobile-sel '[]' \
      --subselect-contacts '[-a1 [-chain A,B] -a2 [-chain C]]' \
      --use-ftdock 'true' \
      --use-hex 'false' \
      --constraint-clashes 0.25 \
      --ftdock-keep 5 \
      --ftdock-angle-step 9 \
      --hex-max-solutions 6000 \
      --scoring-rank-names 'extended_for_protein_protein_no_glob' \
      --scoring-full-top 1000 \
      --scoring-full-top-slow 300 \
      --scoring-ranks-top 100 \
      --scoring-jury-maxs 1 \
      --scoring-jury-slices '3 30' \
      --scoring-jury-cluster "$(seq 0.65 0.01 0.75)" \
      --plot-jury-scores "true" \
      --redundancy-threshold 0.7 \
      --build-complexes 100 \
      --cache-dir ./cache

## Example of protein-RNA docking for running on cluster

    #!/bin/bash
    
    STATICFILE="./input/bigger_molecule.pdb"
    MOBILEFILE="./input/smaller_molecule.pdb"
    JOBNAME="$(basename ${STATICFILE} .pdb)__$(basename ${MOBILEFILE} .pdb)"
    
    sbatch --job-name=rdwf --partition=Cluster --ntasks=1 --cpus-per-task=1 --mem-per-cpu=4000 \
    ${HOME}/git/ftdmp/ftdmp-all \
      --ftdmp-root ${HOME}/git/ftdmp \
      --conda-path ${HOME}/miniconda3 \
      --conda-early 'true' \
      --parallel-docking 32 \
      --parallel-scoring 64 \
      --sbatch-for-ftdock '--job-name=ftdock --partition=Cluster --ntasks=1 --cpus-per-task=1 --mem-per-cpu=8000' \
      --sbatch-for-hex-or-sam '--job-name=hexsam --partition=Cluster --ntasks=1 --cpus-per-task=8 --mem-per-cpu=8000' \
      --sbatch-scoring '--job-name=dscore --partition=Cluster --ntasks=1 --cpus-per-task=1 --mem-per-cpu=8000' \
      --openmm-forcefield '' \
      --relax-complexes '' \
      --job-name "$JOBNAME" \
      --output-dir ./output \
      --static-file "$STATICFILE" \
      --static-sel '[]' \
      --mobile-file "$MOBILEFILE" \
      --mobile-sel '[]' \
      --use-ftdock 'true' \
      --use-hex 'false' \
      --constraint-clashes 0.5 \
      --ftdock-keep 5 \
      --ftdock-angle-step 9 \
      --hex-max-solutions 6000 \
      --subselect-contacts '[-a1 [-chain A] -a2 [-chain B,C]]' \
      --scoring-rank-names 'standard_for_generic' \
      --scoring-full-top 1000 \
      --scoring-full-top-slow 300 \
      --scoring-ranks-top 100 \
      --scoring-jury-maxs 1 \
      --scoring-jury-slices '3 30' \
      --scoring-jury-cluster "$(seq 0.65 0.01 0.75)" \
      --redundancy-threshold 0.7 \
      --build-complexes 100 \
      --cache-dir ./cache


