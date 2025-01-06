# About FTDMP

FTDMP is a software system for running docking experiments and scoring/ranking multimeric models.

FTDMP was used in CASP15 by the "Venclovas" team (Vilnius University / Life Sciences Center / Institute of Biotechnology).
The most novel and useful features of FTDMP are integrated __VoroIF-jury__ and __VoroIF-GNN__ methods.

FTDMP has two main entry-point scripts:

* __ftdmp-all__ - script to perform docking with FTDock/HEX/SAM and subsequent scoring/ranking using VoroIF-jury.
* __ftdmp-qa-all__ - script to perform scoring/ranking using VoroIF-jury - for example, to score a mix of models from different sources (docking, AlphaFold, RoseTTAFold).

FTDMP uses several software tools that are included in the FTDMP package:

* __Voronota__ with its expansion Voronota-JS, namely the following executable:
    * __voronota-js__ (core engine that executes JavaScript scripts)
    * __voronota-js-voromqa__ (wrapper to a voronota-js program for computing VoroMQA scores, both old and new (developed for CASP14))
    * __voronota-js-only-global-voromqa__ (wrapper to a voronota-js program for computing only global VoroMQA scores with fast caching)
    * __voronota-js-fast-iface-voromqa__ (wrapper to a voronota-js program for the very fast computation of the inter-chain interface VoroMQA energy)
    * __voronota-js-fast-iface-cadscore__ (wrapper to a voronota-js program for the very fast computation of the inter-chain interface CAD-score)
    * __voronota-js-fast-iface-cadscore-matrix__ (wrapper to a voronota-js program for the very fast computation of the inter-chain interface CAD-score matrix)
    * __voronota-js-fast-iface-data-graph__ (wrapper to a voronota-js program for the computation of interface graphs used by the VoroIF-GNN method)
    * __voronota-js-voroif-gnn__ (wrapper to a voronota-js program and GNN inference scripts that run the VoroIF-GNN method for scoring models of protein-protein complexes (developed for CASP15))
* __FTDock__ (a modified version of a popular rigid-body-docking software tool), it depends on "fftw-2.1.5" that is also included
* __FASPR__ (a fast tool for rebuilding sidechains in protein structures)

FTDMP also can use non-open-source docking tools that are not included in the FTDMP package, but can be easily installed separately:

* __HEX__ (a rigid-body-docking software tool)
* __SAM__ (a symmetry-docking software tool)

Some features of FTDMP require aditional dependencies (that are easily available through "conda" package manager):

 * graph neural network-based scoring using "voronota-js-voroif-gnn" requires "R", "PyTorch" and "PyTorch Geometric"
 * relaxing using molecular dynamics requires "OpenMM"

# Benchmarks for protein-protein, protein-DNA, and protein-RNA docking 

The benchmark dataset for protein-protein, protein-DNA, and protein-RNA docking is available at [https://doi.org/10.5281/zenodo.10517524](https://doi.org/10.5281/zenodo.10517524).
It contains structures of three docking benchmarks, as well as docking tables.
This dataset together with the FTDMP framework can be used for docking and scoring complexes, as well as evaluating new scoring functions.

# FTDMP publications

If you use the FTDMP for your research, please cite the following articles.

FTDMP software, cleaned docking benchmarks and docking results are published here:

* Olechnovič K, Banciul R, Dapkūnas J, Venclovas Č. (2025) *FTDMP: A Framework for Protein-Protein, Protein-DNA, and Protein-RNA Docking and Scoring*. Proteins. doi: [10.1002/prot.26792](https://doi.org/10.1002/prot.26792). PubMed PMID: [39748638](https://pubmed.ncbi.nlm.nih.gov/39748638/).

Scoring of protein-protein interfaces using the VoroIF-jury algorithm and details of this algorithm are published in our CASP16 article:

* Olechnovič K, Valančauskas L, Dapkūnas J, Venclovas Č. (2023) *Prediction of protein assemblies by structure sampling followed by interface-focused scoring*. Proteins; 91:1724–1733. doi: [10.1002/prot.26569](https://doi.org/10.1002/prot.26569). PubMed PMID: [37578163](https://pubmed.ncbi.nlm.nih.gov/37578163/).

# Obtaining and installing FTDMP

## Getting the latest version

The currently recommended way to obtain FTDMP is cloning the FTDMP git repository [https://github.com/kliment-olechnovic/ftdmp](https://github.com/kliment-olechnovic/ftdmp):

    git clone https://github.com/kliment-olechnovic/ftdmp.git
    cd ./ftdmp

## Building the included software

To build all the included dependencies, run the following command:

    ./core/build.bash

## Installing

To, optionally, make FTDMP accessible without specifying full path, add the following line at the end of ".bash_profile" or ".bashrc":

    export PATH="/path/to/ftdmp:${PATH}"

## Setting Miniconda for using graph neural network-based scoring, and for using OpenMM

Download the Miniconda package:

    cd ~/Downloads
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    
Install Miniconda:

    bash Miniconda3-latest-Linux-x86_64.sh
    
Activate Miniconda environment:

    source ~/miniconda3/bin/activate

Install packages for using graph neural network-based scoring:

    # install PyTorch using instructions from 'https://pytorch.org/get-started/locally/'
    conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
    
    # install PyTorch Geometric using instructions from 'https://pytorch-geometric.readthedocs.io/en/latest/install/installation.html'
    pip install torch_geometric
    pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.1.0+cu121.html
    
    # install Pandas
    conda install pandas
    
    # if you do not have R installed in you system, install it (not necessarily using conda, e.g 'sudo apt-get install r-base' in Ubuntu)
    conda install r -c conda-forge

Test PyTorch installation:

    python -c "import torch; print(torch.__version__)"

Install packages for using OpenMM:

    conda install -c conda-forge libstdcxx-ng # needed for the compatible version of libstdc++
    conda install -c conda-forge openmm
    conda install -c conda-forge pdbfixer

Test OpenMM installation:

    python -m openmm.testInstallation

## Setting up Miniconda using the provided environment configuration file

As an alternative to manually installing packages, it is possible to use the environment configuration file [envs/ftdmp_environment_for_conda.yml](envs/ftdmp_environment_for_conda.yml) provided in the FTDMP repository.

For this, first download+install+activate Miniconda:

    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    source ~/miniconda3/bin/activate

Then create the environment from file:
    
    conda env create -f ftdmp_environment_for_conda.yml

If no other name is specified, then the newly created environment will be called 'ftdmp'.

Note that the usage of the provided configuration file results in installing Pandas, OpenMM, and the CPU versions of PyTorch and PyTorch Geometric.
For CUDA-based PyTorch and PyTorch Geometric packages, the manual installation way, described the previous section, is recommended.

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
        --ranks-top                       number     number of top complexes to consider for each ranking, default is 300
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
    
    Named collections of rank names, to be provided as a single string to '--rank-names':
    
        protein_protein_voromqa_and_global_and_gnn_no_sr
        protein_protein_voromqa_and_global_and_gnn_with_sr
        protein_protein_voromqa_and_gnn_no_sr
        protein_protein_voromqa_and_gnn_with_sr
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
        --geom-hash-to-simplify   number     number of instances per rotation to keep after first scoring, default is 0 to not do it
        --scoring-full-top        number     number of top complexes to keep after full scoring stage, default is 1000
        --scoring-full-top-slow   number     number of top complexes to keep before slow full scoring stage, default is 9999999
        --scoring-rank-names      string  *  rank names to use, or name of a standard set of rank names
        --scoring-rank-names-x    string     extra rank names to use, default is 'all_plugin' to use plugin output columns (if any)
        --scoring-ranks-top       number     number of top complexes to consider for each ranking, default is 100
        --scoring-jury-slices     string     slice sizes sequence definition for ranks jury scoring, default is '5 20'
        --scoring-jury-cluster    number     clustering threshold for ranks jury scoring, default is 0.9
        --scoring-jury-maxs       number     number of max values to use for ranks jury scoring, default is 1
        --redundancy-threshold    number     minimal ordered redundancy value to accept, default is 0.9
        --plugin-scoring-script   string     path to executable script that outputs a table of scores for a PDB structure
        --build-complexes         number     number of top complexes to build, default is 0
        --multiply-chains         string     options to multiply chains, default is ''
        --relax-complexes         string     options to relax complexes, default is ''
        --all-ranks-for-relaxed   string     flag to use both scoring ranks of both raw and relaxed structures, default is 'true'
        --only-dock-and-score     string     flag to only dock, score and quit after scoring, default is 'false'
        --diversify               number     step of CAD-score to diversify scoring results and exit, default is ''
        --plot-jury-scores        string     flag to output plot of jury scores, default is 'false'
        --casp15-qa               string     flag to output CASP15 QA answer, default is 'false'
        --casp15-qa-target        string     target name for outputting CASP15 QA answer, default is '_THETARGET_'
        --casp15-qa-author-id     string     author ID for outputting CASP15 QA answer, default is '_THEAUTHOR_'
        --output-dir              string  *  output directory path
        --help | -h                          flag to display help message and exit
    
    Output:
    
        All the docking and scoring results are placed into directory "${output_dir}/${jobname}"
    
        Main results for raw (unrelaxed) complex models:
            final ordered table with VoroIF-jury scores = "${output_dir}/${jobname}/raw_top_scoring_results_RJS_only.txt"
            directory with built top complex models in PDB format = "${output_dir}/${jobname}/raw_top_complexes"
        
        Main results for relaxed complex models:
            directory with built and relaxed top complex models in PDB format = "${output_dir}/${jobname}/relaxed_top_complexes"
            final ordered table with VoroIF-jury scores = "${output_dir}/${jobname}/relaxed_top_scoring_results_RJS_only.txt"
    
    Examples:
    
        ftdmp-all --job-name 'j1' --static-file './chainA.pdb' --mobile-file './chainB.pdb' \
          --scoring-rank-names 'protein_protein_voromqa_and_global_and_gnn_no_sr' --output-dir './results'
    
        ftdmp-all --job-name 'j2' --pre-docked-input-dir './predocked' \
          --scoring-rank-names 'protein_protein_voromqa_and_gnn_no_sr' --output-dir './results'
    
    Named collections of rank names, to be provided as a single string to '--scoring-rank-names':
    
        protein_protein_voromqa_and_global_and_gnn_no_sr
        protein_protein_voromqa_and_global_and_gnn_with_sr
        protein_protein_voromqa_and_gnn_no_sr
        protein_protein_voromqa_and_gnn_with_sr
        protein_protein_voromqa_no_sr
        protein_protein_voromqa_with_sr
        protein_protein_simplest_voromqa
        generalized_voromqa

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
      --ftdock-keep 10 \
      --ftdock-angle-step 6 \
      --geom-hash-to-simplify 1 \
      --scoring-rank-names 'protein_protein_voromqa_and_global_and_gnn_no_sr' \
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

## Example of protein-DNA docking for running on cluster

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
      --static-chain 'A' \
      --mobile-file "$MOBILEFILE" \
      --mobile-sel '(not [-rnum 1 -aname P,O1P,O2P,O3P,OP1,OP2,OP3])' \
      --mobile-chain 'A=B,B=C' \
      --subselect-contacts '[-a1 [-chain A] -a2 [-chain B,C]]' \
      --use-ftdock 'true' \
      --use-hex 'false' \
      --constraint-clashes 0.9 \
      --ftdock-keep 10 \
      --ftdock-angle-step 6 \
      --geom-hash-to-simplify 1 \
      --scoring-rank-names 'generalized_voromqa' \
      --scoring-full-top 3000 \
      --scoring-ranks-top 200 \
      --scoring-jury-maxs 1 \
      --scoring-jury-slices '5 50' \
      --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
      --redundancy-threshold 0.7 \
      --build-complexes 200 \
      --openmm-forcefield 'amber14-all-no-water' \
      --relax-complexes '--max-iterations 10 --focus whole_interface' \
      --cache-dir ./cache

Main essential changes when compared with the protei-protein docking case:

    --scoring-rank-names 'generalized_voromqa'
    
    --openmm-forcefield 'amber14-all-no-water'                        # now using a force field that is compatible with DNA and RNA
    --relax-complexes '--max-iterations 10 --focus whole_interface'   # now using iterations limit to not overdo the relaxation in absence of water

## Using a plugin script to score docking models

'ftdmp-all' can accept a plugin script that outputs one or more scoresa for an input model structure in PDB format.
Such a script must:

 * accept two command line argument: input file, output file
 * write an output file with two lines: first line with space-separated score names, second line with score values

Example of a plugin script:

    #!/bin/bash
    
    INFILE="$1"
    OUTFILE="$2"
    
    {
        echo "Useful_Score1 Useful_Score2 Useful_Score3"
        ${HOME}/software/program_that outputs_three_scores "$INFILE"
    } \
    > "$OUTFILE"

Example of a plugin script output:

    Useful_Score1 Useful_Score2 Useful_Score3
    0.85 1.73 104.9

When providing a plugin script script file with

    --plugin-scoring-script ./plugin.bash

and not providing anything with '--scoring-rank-names-x',
the default behaviour is to automatically use all the scores from the plugin script output.

Alternatively, space-separated score names with 'raw_' prefix can be provided, e.g.

    --plugin-scoring-script ./plugin.bash --scoring-rank-names-x "raw_Useful_Score1 raw_Useful_Score3"

Important note - the plugin scores are assummed to be "the higher, the better", i.e. for ranking they are sorted in descending order.

# Using FTDMP for relaxing structures with OpenMM to remove clashes and improve interface interactions

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
        
        ftdmp-relax-with-openmm --conda-path ~/miniconda3 --forcefield amber14-all \
          -i model.pdb -o relaxed_model.pdb --score-at-end fast_iface --trim-output

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
            --forcefield 'amber14-all-no-water' \
            --max-iterations 10 \
            --focus "whole_interface" \
            --input "$INFILE" \
            --output "$OUTFILE" \
            --cache-dir ./workdir/relax_cache
    done

