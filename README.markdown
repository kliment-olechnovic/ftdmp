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

Scoring and ranking is done with the 'ftdmp-qa-all' script.
Below is the breef description of 'ftdmp-qa-all' interface.

## Command line user interface

    'ftdmp-qa-all' scores and ranks multimeric structures of proteins or nucleic acids
    
    Options:
        --workdir                         string  *  path to directory for caching and writing detailed results
        --subselect-contacts              string     query to subselect inter-chain contacts for scoring, default is '[]'
        --constraints-required            string     query to check required inter-chain contacts, default is ''
        --constraints-banned              string     query to check banned inter-chain contacts, default is ''
        --constraint-clashes              number     max allowed clash score, default is ''
        --subselect-atoms-global          string     query to subselect atoms for global scores, default is '[]'
        --reference                       string     input structure file to compute CAD-score with, default is ''
        --ftdmp-root                      string     ftdmp root path, default is '' (autodetected from the calling command)
        --conda-path                      string     conda installation path, default is ''
        --conda-early                     string     flag to activate conda as early as possible
        --conda-env                       string     conda main environment name, default is ''
        --processors                      number     number of processes to run when scoring, default is 8
        --sbatch                          string     sbatch parameters to run scoring in parallel, default is ''
        --score-symmetry                  string     flag to score symmetry, default is 'false'
        --external-scores                 string     path to input file with external scores table, default is ''
        --remap-cadscore                  string     flag to use optimal chains remapping for CAD-score, default is 'false'
        --crude-cadscore                  string     flag to use faster but crude mode for CAD-score
        --keep-top-fast                   number     number of top complexes to keep after full scoring stage, default is 9999999
        --keep-top-slow                   number     number of top complexes to keep before slow full scoring stage, default is 9999999
        --limit-voromqa-light             number     minimal allowed VoroMQA-light whole-stricture score, default is ''
        --rank-names                      string     rank names to use, or name of a standard set of rank names, default is 'protein_protein_voromqa_and_global_and_gnn_no_sr'
        --ranks-top                       number     number of top complexes to consider for each ranking, default is 9999999
        --jury-slices                     string     slice sizes sequence definition for ranks jury scoring, default is '5 20'
        --jury-cluster                    number     clustering threshold for ranks jury scoring, default is 0.9
        --jury-maxs                       number     number of max values to use for ranks jury scoring, default is 1
        --output-redundancy-threshold     number     minimal ordered redundancy value to accept, default is 0.9
        --plot-jury-scores                string     file path to output plot of jury scores, default is ''
        --plot-jury-diagnostics           string     flag to plot jury diagnostics, default is 'false'
        --write-pdb-file                  string     file path template to output scores in PDB files, default is ''
        --write-pdb-mode                  string     mode for PDB scores output ('voromqa_dark' or 'voromqa_dark_and_gnn'), default is 'voromqa_dark_and_gnn'
        --write-pdb-num                   number     number of top PDB files with scores to write, default is 5
        --write-full-table                string     file path to output full table, default is ''
        --help | -h                                  flag to display help message and exit
    
    Standard input:
        input file paths
    
    Standard output:
        space-separated table of scores
    
    Examples:
    
        ls ./*.pdb | ftdmp-qa-all --conda-path ~/miniconda3 --workdir './tmp/works' --rank-names protein_protein_voromqa_and_global_and_gnn_no_sr
        
        ls ./*.pdb | ftdmp-qa-all --workdir './tmp/works' --rank-names protein_protein_voromqa_no_sr
        
        ls ./*.pdb | ftdmp-qa-all --conda-path ~/miniconda3 --workdir './tmp/works' --rank-names protein_protein_voromqa_and_global_and_gnn_no_sr \
            --write-pdb-file './output/scored_-RANK-_-BASENAME-' --write-pdb-mode 'voromqa_dark_and_gnn' --write-pdb-num 5
    
    Named collections of rank names:
    
        protein_protein_voromqa_and_global_and_gnn_no_sr
        protein_protein_voromqa_and_global_and_gnn_with_sr
        protein_protein_voromqa_no_sr
        protein_protein_voromqa_with_sr
        protein_protein_simplest_voromqa
        generalized_voromqa

## Scoring and ranking multimeric protein models using all available scoring tools

Example of scoring using only interface-focused methods:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names protein_protein_voromqa_and_gnn_no_sr \
      --conda-path ~/miniconda3 \
      --workdir './works'
    
Example of scoring using both interface-focused and whole-structure methods:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names protein_protein_voromqa_and_global_and_gnn_no_sr \
      --conda-path ~/miniconda3 \
      --workdir './works'

## Scoring and ranking multimeric protein models without using graph neural networks

Example of scoring with rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names protein_protein_voromqa_with_sr \
      --workdir './works'
    
Example of scoring without rebuilding side-chains:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names protein_protein_voromqa_no_sr \
      --workdir './works'

## Scoring and ranking multimeric models that include RNA or DNA:

Example of scoring:

    ls ./*.pdb \
    | ftdmp-qa-all \
      --rank-names generalized_voromqa \
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
        --static-rotation-seed    number     random seed to initially rotate static part, default is 1
        --mobile-file             string     hetero or homo docking mobile input file path
        --mobile-sel              string     hetero or homo docking query to restrict mobile atoms, default is '[]'
        --mobile-chain            string     hetero or homo docking chain name or chain renaming rule to apply for mobile atoms, default is ''
        --mobile-rotation-seed    number     random seed to initially rotate mobile part, default is 2
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
        --scoring-full-top-slow   number     number of top complexes to keep before slow full scoring stage, default is 9999999
        --scoring-rank-names      string  *  rank names to use, or name of a standard set of rank names
        --scoring-ranks-top       number     number of top complexes to consider for each ranking, default is 100
        --scoring-jury-slices     string     slice sizes sequence definition for ranks jury scoring, default is '5 20'
        --scoring-jury-cluster    number     clustering threshold for ranks jury scoring, default is 0.9
        --scoring-jury-maxs       number     number of max values to use for ranks jury scoring, default is 1
        --redundancy-threshold    number     minimal ordered redundancy value to accept, default is 0.9
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

Example script:

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
      --job-name "$JOBNAME" \
      --output-dir ./output \
      --static-file "$STATICFILE" \
      --static-sel '[]' \
      --static-chain 'D=A,E=B' \
      --mobile-file "$MOBILEFILE" \
      --mobile-sel '[]' \
      --mobile-chain 'C' \
      --subselect-contacts '[-a1 [-chain A,B] -a2 [-chain C]]' \
      --use-ftdock 'true' \
      --use-hex 'false' \
      --constraint-clashes 0.5 \
      --ftdock-keep 5 \
      --ftdock-angle-step 5 \
      --scoring-rank-names 'extended_for_protein_protein_no_sr' \
      --scoring-full-top 3000 \
      --scoring-ranks-top 100 \
      --scoring-jury-maxs 1 \
      --scoring-jury-slices '5 20' \
      --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
      --redundancy-threshold 0.7 \
      --build-complexes 200 \
      --openmm-forcefield 'amber99sb' \
      --relax-complexes '--max-iterations 0 --focus whole_interface' \
      --cache-dir ./cache

## Example of protein-RNA docking for running on cluster

Example script:

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
      --job-name "$JOBNAME" \
      --output-dir ./output \
      --static-file "$STATICFILE" \
      --static-sel '[]' \
      --mobile-file "$MOBILEFILE" \
      --mobile-sel '[]' \
      --subselect-contacts '[-a1 [-chain A] -a2 [-chain B,C]]' \
      --use-ftdock 'true' \
      --use-hex 'false' \
      --constraint-clashes 0.9 \
      --ftdock-keep 5 \
      --ftdock-angle-step 5 \
      --scoring-rank-names 'standard_for_generic' \
      --scoring-full-top 3000 \
      --scoring-ranks-top 200 \
      --scoring-jury-maxs 1 \
      --scoring-jury-slices '5 50' \
      --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
      --redundancy-threshold 0.7 \
      --build-complexes 200 \
      --openmm-forcefield 'amber14-all-no-water' \
      --relax-complexes '--max-iterations 0 --focus whole_interface' \
      --cache-dir ./cache

Main essential changes when compared with the protei-protein docking case:

    --scoring-rank-names 'standard_for_generic'
    
    --openmm-forcefield 'amber14-all-no-water'
    
    

# Using FTDMP for relaxing structures with OpenMM to remove clashes and improve interface interactions

## Installing OpenMM

The easiest way to install OpenMM is to do it in a Miniconda Anaconda environment:

    conda install -c conda-forge openmm

## Command line user interface

Relaxing is done with the 'ftdmp-relax-with-openmm' script.
After relaxing, model structures can be rescored and reranked with the 'ftdmp-qa-all' script.
It is advised to do it on a machine with a nice GPU.
Below is the breef description of 'ftdmp-relax-with-openmm' interface.

    'ftdmp-relax-with-openmm' script relaxes a molecular structure using OpenMM.
    
    Options:
        --input                   string  *  input file path
        --output                  string  *  output file path, setting to '_same_as_input' will overwrite input file
        --focus                   string     focus mode, default is 'whole_structure', others are: 'interface_side_chains', 'whole_interface', 'not_interface'
        --focus-base              string     selection of atoms that can be in a partial structure focus, default is '[]'
        --focus-first-sel         string     first selection of atoms to define interface not by chains, default is ''
        --focus-second-sel        string     second selection of atoms to define interface not by chains, default is ''
        --conda-path              string     conda installation path, default is ''
        --conda-env               string     conda environment name, default is ''
        --forcefield              string     forcefield combo name, default is 'amber99sb', others are: 'amber14-all', 'amber14-all-no-water', 'charmm36'
        --main-forcefield         string     main forcefield name, default is defined by the combo name, some others are: 'amber99sb', 'amber14-all', 'charmm36'
        --water-forcefield        string     water forcefiled name, default is defined by the combo name, some others are: '', 'amber99_obc', 'amber14/tip3pfb', 'charmm36/water'
        --max-iterations          number     max number of iterations, default is 100
        --score-at-end            string     mode for scoring interface at the end, default is '', others are: 'fast_iface', 'full_iface', 'full'
        --scoring-params          string     additional parameters for scoring, default is ''
        --multiple-tries          number     number of tries to generate and score interfaces, default is ''
        --cache-dir               string     cache directory path to store results of past calls
        --force-cuda                         flag to force the platform to be CUDA
        --trim-output                        flag to restrict output to atoms of proteins and nucleic acids
        --no-preparation                     flag to not run any preparation of input structure before simulations
        --limit-preparation                  flag to only add solvent if needed in the preparation stage
        --full-preparation                   flag to turn off all preparation disabling flags
        --no-simulation                      flag to not run any simulations
        --help | -h                          flag to display help message and exit
    
    Standard output:
        space-separated table of scores for both input and output
        
    Examples:
    
        ftdmp-relax-with-openmm --input model.pdb --output relaxed_model.pdb
        
        ftdmp-relax-with-openmm --conda-path ~/anaconda3 --conda-env alphafold2 \
          --forcefield amber14-all -i model.pdb -o relaxed_model.pdb --score-at-end fast_iface --trim-output

## Example of relaxing multiple complex structures containing chains of different types (protein, nucleic acid)

Using the 'amber14-all-no-water' forcefield, the example below works for protein-protein, protein-nucleic acid, and nucleic acid-nucleic acid interfaces.

    find "./models/raw/" -type f -name '*.pdb' \
    | while read -r INFILE
    do
        OUTFILE="./models/relaxed/$(basename ${INFILE})"
        
        ${HOME}/git/ftdmp/ftdmp-relax-with-openmm \
            --conda-path ${HOME}/miniconda3 \
            --conda-env '' \
            --force-cuda \
            --full-preparation \
            --forcefield amber14-all-no-water \
            --focus "whole_interface" \
            --input "$INFILE" \
            --output "$OUTFILE" \
            --cache-dir ./workdir/relax_cache
    done

