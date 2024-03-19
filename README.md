<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->


<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/rmercuri/freddie">
    <img src="assets/img/Logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Freddie</h3>

  <p align="center">
    A tool to identify exonization of retrotransposable elements using RNA-seq data. 
    <br />
    <a href="https://github.com/rmercuri/freddie"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/rmercuri/freddie">View Demo</a>
    ·
    <a href="https://github.com/rmercuri/freddie/issues">Report Bug</a>
    ·
    <a href="https://github.com/rmercuri/freddie/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#overview">Overview</a></li>
    <li>
      <a href="#installation">Installation</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#databases">Databases</a></li>
      </ul>
    </li>
    <li><a href="#commands-and-options">Commands and options</a></li>
    <li>
      <a href="#running">Running</a>
      <ul>
        <li><a href="#star">Star</a></li>
        <li><a href="#string">StringTie</a></li>
        <li><a href="#chimeric">Chimeric</a></li>
        <li><a href="#coding">Coding</a></li>
        <li><a href="#pfam">Pfam</a></li>
        <li><a href="#expression">Expression</a></li>
        <li><a href="#results">Results</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#authors">Authors</a></li>
  </ol>
</details>

<!-- OVERVIEW -->
## Overview
Freddie is a user-friendly pipeline designed to identify, quantify, and analyze chimeric transcripts from RNA-Seq data. The pipeline utilizes well-established tools such as StringTie2 for transcriptome assembly and quantification. In addition, machine learning algorithms provided by RNASamba are used to predict whether a transcript is coding. To further enhance the analysis, Freddie also incorporates HMMER and Python3 scripts to compare protein domains and identify potential alterations. With these tools, Freddie provides a comprehensive approach to chimeric transcript analysis that is both efficient and effective.

<a href="https://github.com/rmercuri/freddie">
    <img src="assets/img/Workflow.png" alt="Workflow" width="1800" height="500">
</a>

<!-- INSTALLATION -->
### Installation
The source code for FREDDIE can be obtained in our github page using this command line:

`git clone https://github.com/galantelab/freddie.git`

Inside FREDDIE’s directory, build a docker image:

`cd freddie`

`docker build -f Dockerfile -t freddie .`

### Databases
We provide all the necessary databases to run FREDDIE, catering to human functionality. In our comprehensive documentation available in paper supplementary material, we offer a step-by-step guide to generating these exact files for other species.


File | Description | Link
------------ | ------------- | -------------
star_index | Folder with STAR Index builded with hg38.fa and gencodev36 | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/star_index.tar.gz
gencode.v36.annotation.gtf | GTF file (Used in TCGA) | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/gencode.v36.annotation.gtf
hg38.fa | Reference Genome | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/hg38.fa
hg38.fa.fai | Index of reference genome | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/hg38.fa.fai
hg38.pep.fa | Aminoacid sequences of proteins | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/hg38.pep.fa
model.hdf5 | RNASamba model (Works to mammals in general) | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/human38_model.hdf5
Pfam-A.hmm | HMMER model (Works to mammals in general) you need download all files with .hmm* | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/Pfam-A.hmm
Pfam-A.hmm.h3f | HMMER model (Works to mammals in general) you need download all files with .hmm* | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/Pfam-A.hmm.h3f
Pfam-A.hmm.h3i | HMMER model (Works to mammals in general) you need download all files with .hmm* | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/Pfam-A.hmm.h3i
Pfam-A.hmm.h3m | HMMER model (Works to mammals in general) you need download all files with .hmm* | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/Pfam-A.hmm.h3m
Pfam-A.hmm.h3p | HMMER model (Works to mammals in general) you need download all files with .hmm* | https://bioinfohsl-tools.s3.amazonaws.com/freddie/databases/Pfam-A.hmm.h3p

to `star_index.tar.gz` you shoul uncompress the folder:

`tar -xvf filename.tar.gz` 

<!-- COMMANDS AND OPTIONS -->
## Commands and options
FREDDIE has seven subcommands: “star”, “string”, “chimeric”, “coding”, “pfam”, “expression” and “results”.

`freddie [subcommand] <options>`

Subcommands may be invoked by the help menu:

`freddie help`

7 subcommands are avaiable:

Subcommand | Description
------------ | -------------
star | Align RNA-seq data against the genome using STAR (DOI: 10.1093/bioinformatics/bts635)
string | Assemble sequenced reads (compatible with both short and long reads) using StringTie2 (DOI: 10.1186/s13059-019-1910-1)
chimeric | Identify potential chimeric transcripts
coding | Compute the coding potential of (chimeric) transcripts using RNASamba (DOI: https://doi.org/10.1093/nargab/lqz024)
pfam | Search for protein domains using HMMer (DOI: 10.1093/nar/gkr367) and Pfam protein families and domains (https://doi.org/10.1093/nar/gkaa913)
expression | Estimate transcript expression using StringTie2 (DOI: 10.1186/s13059-019-1910-1)
results | Compile the final results of chimeric transcripts incorporating inputs from previous steps

<!-- RUNNING -->
## Star
The first step in the FREDDIE’s pipeline is the “star”. The inputs to this command are FASTQ files and a STAR index (pre-made available at: www.bioinfo.mochsl.org.br/freddiesdata/STAR_index/). The sorted and filtered BAM  aligned file resulting from this command will become the input to the next step. This command supports all types of RNA-Seq data (paired-end, single-end and long-reads), either compressed (.gz) or not.

star options are:

Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-i | --index-dir | STAR index directory
-f | --file | File containing a newline separated list of sequencing files in FASTQ format. This option is not mandatory if one or more FASTQ files are passed as argument.
-h | --help | Print help message
-t | --threads | Number of threads [default: 8]
-S | --short-reads | Set the sequencing to short reads [default]
-L | --long-reads | Set the sequencing to long reads
-s | --single-end | For short reads '-S', set the type of sequencing to single-end
-p | --paired-end | For short reads '-S', set the type of sequencing to paired-end. In this case, the FASTQ files will be processed, being considered forward (R1) and reverse complement (R2) according to the order in which they are passed [default]

**Example**

`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <star_index-path>:/home/freddie/star_index/ -v <fastq-path>:/home/freddie/input/ -v <output-path>:/home/freddie/output/ freddie star -o test -i /home/freddie/star_index/ -f /home/freddie/input/<fastq-path>`

Whereas:

`<star_index-path>` is the directory where star_index was downloaded. Ex.: `$PWD/star_index/`

`<fastq-file-path>` is the directory where all fastq files are. Ex.: if `$PWD/*fastq.gz` type `$PWD/`

`<output-path>` is the output directory. Ex.: `$PWD/output/`

`<fastq-path>` is a .txt file inside `/home/freddie/input/` with the docker path (somethig like `/home/freddie/input/test.fastq.gz`) to the fastq files.

### String  
The next step in the pipeline is “string”. This command performs a transcriptome assembly with the BAMs generated in the previous step (or custom BAMs provided by the user). The output of this analysis is a GTF file representing the transcriptome from all samples.

String options are:

Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-a | --annotation | Gene annotation of the reference genome transcriptome in GTF format
-f | --file | File containing a newline separated list of sequencing files in FASTQ format. This option is not mandatory if one or more FASTQ files are passed as argument.
-h | --help | Print help message
-t | --threads | Number of threads [default: 8]
-S | --short-reads | Set the sequencing to short reads [default]
-L | --long-reads | Set the sequencing to long reads

**Example**

`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <gtf-file-path>:/home/freddie/gtf/ -v <output-path>:/home/freddie/output/ freddie string -o test -a /home/freddie/gtf/<gtf-file>`

Whereas:

`<gtf-file-path>` is the directory where gtf was downloaded. Ex.: if `$PWD/gencodev36.annotation.gtf` type `$PWD/`

`<output-path>` is the output directory. Ex.: `$PWD/output/`

`<gtf-file>` is a gtf inside /home/freddie/gtf/. Ex.: `/home/freddie/gtf/gencodev36.annotation.gtf`

### Chimeric
In the “chimeric” step, the pipeline identifies novel transcripts based on the GTF file generated from the “string” command. Here, FREDDIE uses a list of events provided by the user to find transcripts with overlap between exons and the given events. Again, a GTF file and also a FASTA file with all transcripts found are the outputs provided.

<a href="https://github.com/rmercuri/freddie">
    <img src="assets/img/scheme_quimeric.jpg" alt="Chimeric transcript" width="1800" height="500">
</a>

Chimeric options are:

Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-a | --annotation | Gene annotation of the reference genome transcriptome in GTF format
-g | --genome | FASTA file of the reference genome,which is the same file used for reads alignment using STAR
-e | --stringtie-out | StringTie2 output events file in BED4
-h | --help | Print help message
-T | --tmp-dir | Uses directory for temporaries [default: /tmp]
-r | --reciprocal | Criteria for identifying chimeric events is 50% overlap of the event with the exon and 50% overlap of the exon with the event
-R | --irreciprocal | Criteria for identifying chimeric events is 50% overlap of the event with the exon [default]

**Example**

`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <gtf-file-path>:/home/freddie/gtf/ -v <genome-file-path>:/home/freddie/ref_fa/ -v <events-file-path>:/home/freddie/events/ -v <output-path>:/home/freddie/output/ freddie chimeric -o test -g /home/freddie/gtf/<gtf-file> -G /home/freddie/ref_fa/<genome-file> -i /home/freddie/events/<event-file>`

Whereas:

`<gtf-file-path>` is the directory where gtf was downloaded. Ex.: if `$PWD/gencodev36.annotation.gtf` type `$PWD/`

`<genome-file-path>` is the directory where the reference genome and reference genome index were downloaded. Ex.: if `$PWD/hg38.fa` type `$PWD/`

`<events-file-path>` is the directory where the events are. Ex.: if `$PWD/events.bed` type `$PWD/`

`<output-path>` is the output directory. Ex.: `$PWD/output/`

`<gtf-file>` is a gtf inside `/home/freddie/gtf/`. Ex.: `/home/freddie/gtf/gencodev36.annotation.gtf`

`<genome-file>` is a .fa inside `/home/freddie/ref_fa/`. Ex.: `/home/freddie/ref_fa/hg38.fa`

`<events-file>` is a .bed inside `/home/freddie/events/`. Ex.: `/home/freddie/events/events.bed`

### Coding
The “coding” command classifies the novel transcripts identified in the “chimeric” step as coding or non coding. Here, FREDDIE uses a model trained by RNASamba (available at: www.bioinfo.mochsl.org.br/freddiesdata/model.hdf5) to calculate the probability of a transcript being coding. In the end, a FASTA file with the protein sequences of all transcripts considered coding by our criteria is created.
  
Coding options are:
Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-m | --protein-model | File with the model of RNASamba
-d | --protein-db | File with the protein sequences
-h | --help | Print help message
-P | --probability | Set the cutoff for selecting transcripts considered to be protein-coding, based on the probability provided by RNASamba [default: 0.9]

**Example**

`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <rnasambamodel-file-path>:/home/freddie/rnasamba/ -v <proteinseq-file-path>:/home/freddie/proteinseq/ -v <output-path>:/home/freddie/output/ freddie coding -o test -m /home/freddie/rnasamba/<rnasambamodel-file> -d /home/freddie/proteinseq/<proteinseq-file>`

Whereas:

`<rnasambamodel-file-path>` is the directory where rnasamba model was downloaded. Ex.: if `$PWD/model.hdf5` type `$PWD/`

`<proteinseq-file-path>` is the directory where the proteinseq was downloaded. Ex.: if `$PWD/hg38.pep.fa` type `$PWD/`

`<output-path>` is the output directory. Ex.: `$PWD/output/`

`<rnasambamodel-file>` is a .hdf5 inside `/home/freddie/rnasamba/`. Ex.: `/home/freddie/rnasamba/model.hdf5`

`<proteinseq-file>` is a .fa inside `/home/freddie/proteinseq/`. Ex.: `/home/freddie/proteinseq/hg38.pep.fa`

### Pfam
The “pfam” step searches for protein domains in the novel transcripts that passed the user’s predefined coding probability and subsequently compares them with the host’s protein domains. In order to identify the protein domains, we used HMMER trained with the PFAM database. The output of this command is a TSV file comparing the protein domains of the novel transcripts identified with those of the host genes.
  
Pfam options are:
Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-M | --pfam-model | A database of protein domain families to be used as an index for HMmer tool
-h | --help | Print help message
-T | --tmp-dir | Uses directory for temporaries [default: /tmp]
-t | --threads | Number of threads [default: 4]
-E | --e-value | In the HMMER per-target output, reports target sequences with an e-value lesser than NUM [default: 1e-6]

**Example**
  
`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <pfammodel-file-path>:/home/freddie/pfammodel/ -v <output-path>:/home/freddie/output/ freddie pfam -o test -M <pfammodel-file>`

Whereas:

`<pfammodel-file-path>` is the directory where pfam model was downloaded. Ex.: if `$PWD/Pfam-A.hmm` type `$PWD/`

`<output-path>` is the output directory. Ex.: `$PWD/output/`

`<pfammodel-file> is a .hmm inside `/home/freddie/pfammodel/`. Ex.: `/home/freddie/pfammodel/Pfam-A.hmm`

### Expression
The “expression” command quantifies all the transcriptomes assembled by the StringTie2 “expression” function. The expression results, in TPM (transcript per million) per transcript per sample, are made available as a TSV file.

Expression options are:
Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-f | --file | File containing a newline separated list of sequencing files in FASTQ format. This option is not mandatory if one or more FASTQ files are passed as argument.
-h | --help | Print help message
-T | --tmp-dir | Uses directory for temporaries [default: /tmp]
-t | --threads | Number of threads [default: 8]
-S | --short-reads | Set the sequencing to short reads [default]
-L | --long-reads | Set the sequencing to long reads

**Example**
 
`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <output-path>:/home/freddie/output/ freddie expression -o test`

Whereas:

`<output-path>` is the output directory. Ex.: `$PWD/output/`

### Results
Finally, the “results” command compiles all relevant information from the previous steps. In addition, if the novel transcripts contribute to the expression of their host genes, this step further generates boxplots to show the relative contribution of such expression patterns.

Results options are:
Short options | Long options | Description
------------ | ------------- | -------------
-o | --output-dir | Output directory. Creates the directory if it does not exist
-h | --help | Print help message
-T | --tmp-dir | Uses directory for temporaries [default: /tmp]

**Example**
  
`docker run --rm -u $(id -u):$(id -g) -w $(pwd) -v <output-path>:/home/freddie/output/ freddie results -o test`

Whereas:

`<output-path>` is the output directory. Ex.: `$PWD/output/`

<!-- LICENSE -->
## License

<!-- CONTACT -->
## Contact

Rafael Luiz Vieira Mercuri - (rmercuri@mochsl.org.br)

Project Link: [https://github.com/galantelab/freddie](https://github.com/galantelab/freddie)

<!-- AUTHORS -->
## Authors
Rafael Luiz Vieira Mercuri

Thiago Luiz Araújo Miller

Filipe Ferreira dos Santos

Matheus de Lima

Aline Rangel-Pozzo

Pedro Alexandre Favoretto Galante

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: assets/img/screenshot.png
