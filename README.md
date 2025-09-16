# INF-ACT

This pipeline performs **trimming, metagenomic classification, human alignment, and viral mapping** on paired-end FASTQ samples using Docker containers and a dynamic workflow via Nextflow.
This workflow is created to be used with kit NEB next ultra TM II directional RNA low input (without UMI).

## Key Features:

- Trimming with `bbduk`
- Quality control with `FastQC`
- Taxonomic classification with `Kraken2` (standard 8GB DB)
- Human genome alignment using `STAR`
- Unmapped-to-human aligned to the viral genome using `BWA` 
- Viral transcript quantification using `Salmon`
- Summary reporting with `MultiQC`

## Input: 

A CSV file with the following columns:

| sample_name | input_path                                             | virus_to_detect    | project_name |
|-------------|--------------------------------------------------------|--------------------|--------------|
| S1        --| /path_to_data/S1_R1.fastq.gz;/path_to_data/S1_R2.gz    |Toscana phlebovirus |    Name_X    |

- `input_path`: semicolon-separated paths to R1 and R2 FASTQ files
- `Virus_to_detect`: exact virus name to search for in the Kraken2 report

```text
┌──────────────┐      ┌──────────────────────────┐      ┌───────────────────────┐
│  CSV INPUT   │ ──▶  │     PREPROCESSING        │ ──▶  │    ALIGNMENT (STAR)   │
│ (samples)    │      │ FastQC → BBDUK → FastQC  │      │ Human genome mapping  │
└──────────────┘      └───────────┬──────────────┘      │ Outputs unmapped reads│
                                  │                     └───────────┬───────────┘
                                  │                                 │
                                  ▼                                 ▼
                        ┌───────────────────────┐      ┌──────────────────────┐
                        │   CLASSIFICATION      │      │  VIRAL ALIGNMENT     │
                        │   (Kraken2 DB)        │      │   (BWA-MEM2)         │
                        │ Taxonomic profiling   │      │ Align unmapped reads │
                        └───────────┬───────────┘      │ → virus.bam          │
                                    │                  └───────────┬──────────┘
                                    │                              │
                                    ▼                              ▼
                        ┌────────────────────────┐      ┌──────────────────────┐
                        │    MULTIQC REPORT      │ ◀─── │   QUANTIFICATION     │
                        │ Aggregates reports     │      │ (Salmon)             │
                        │ FastQC, STAR, Kraken   │      │ Viral gene counts    │
                        │ Salmon → report.html   │      │ → quant.sf           │
                        └────────────────────────┘      └──────────────────────┘
```