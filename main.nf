#!/usr/bin/env nextflow

/* nextflow.enable.dsl = 2

include { PREPROCESSING }   from './workflows/1_preprocessing'
include { CLASSIFICATION }  from './workflows/2_classification'
include { ALIGNMENT }       from './workflows/3_alignment'
include { VIRAL_ALIGNMENT } from './workflows/5_viral_alignment'
include { QUANTIFICATION }  from './workflows/4_quantification'
include { MULTIQC }         from './modules/multiqc'
include { BWA_INDEX_VIRAL } from './modules/bwa_index_viral'
include { SALMON_INDEX_VIRAL } from './modules/salmon_index_viral'

workflow NEGEDIA {

    // -------------------------------------------------
    // 1. Leggi CSV e crea il channel dei samples
    // -------------------------------------------------
    samples = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            def (r1, r2) = row.input_path.split(';')
            tuple(
                row.sample_name,
                row.project_name,
                row.virus_to_detect,
                [file(r1), file(r2)] // lista di file R1 e R2
            )
        }

    // Get a single project_name from the samples channel
    project_name_final = samples.map { it[1] }.unique().collect()

    // -------------------------------------------------
    // 2. Pre-processing reads
    // -------------------------------------------------
    preprocessing_out = PREPROCESSING(samples)

    // -------------------------------------------------
    // 3. Creazione indici virali
    // -------------------------------------------------
    viral_bwa_index    = BWA_INDEX_VIRAL(params.viral_fa, project_name_final)
    viral_salmon_index = SALMON_INDEX_VIRAL(params.viral_fa, project_name_final)

    // -------------------------------------------------
    // 4. Allineamento umano (STAR)
    // -------------------------------------------------
    alignment_out = ALIGNMENT(preprocessing_out.trimmed, project_name_final)

    // -------------------------------------------------
    // 5. Estrazione reads non mappate da STAR
    // -------------------------------------------------
    unmapped_reads_from_star = alignment_out.star_results.map {
        sample_id, project_name, virus_to_detect, aligned_bam, unmapped_r1, unmapped_r2, log_file ->
        tuple(sample_id, project_name, virus_to_detect, unmapped_r1, unmapped_r2)
    }

    // -------------------------------------------------
    // 6. Allineamento virale (BWA-MEM2)
    // -------------------------------------------------
    viral_alignment_out = VIRAL_ALIGNMENT(unmapped_reads_from_star, viral_bwa_index, project_name_final)

    // -------------------------------------------------
    // 7. Classificazione Kraken2
    // -------------------------------------------------
    classification_out = CLASSIFICATION(preprocessing_out.trimmed, project_name_final)

    // -------------------------------------------------
    // 8. Quantificazione espressione virale (Salmon)
    // -------------------------------------------------
    quantification_out = QUANTIFICATION(unmapped_reads_from_star, viral_salmon_index, project_name_final)

    // -------------------------------------------------
    // 9. Raccolta di tutti i file QC per MultiQC
    // -------------------------------------------------
    all_qc_files = preprocessing_out.raw_qc_html
        .mix(preprocessing_out.raw_qc_zip)
        .mix(preprocessing_out.trimmed_qc_html)
        .mix(preprocessing_out.trimmed_qc_zip)
        .mix(classification_out.kraken_reports.map { it[3] })   // report Kraken
        .mix(alignment_out.star_results.map { it[6] })          // log STAR
        .mix(quantification_out.quant_res.map { it[3] })        // log Salmon
        .map { file -> tuple(file, project_name_final) }        // tuple richiesta da MultiQC

    // -------------------------------------------------
    // 10. MultiQC finale
    // -------------------------------------------------
    MULTIQC(all_qc_files)

    // -------------------------------------------------
    // 11. Log finale
    // -------------------------------------------------
    log.info """
    =========================================
        INF-ACT PROJECT PIPELINE (NEGEDIA)
    =========================================
    Project name        : ${project_name_final}
    Samplesheet         : ${params.input}
    Output directory    : ${params.outdir}
    Viral genome FASTA  : ${params.viral_fa}
    Human genome index  : ${params.star_idx}
    Kraken2 DB          : ${params.kraken_db}
    =========================================
    """
}

// -------------------------------------------------
// Definizione del workflow principale
// -------------------------------------------------
workflow {
    NEGEDIA()
} */

nextflow.enable.dsl = 2

// Inclusione dei workflow e moduli
include { PREPROCESSING }      from './workflows/1_preprocessing'
include { CLASSIFICATION }     from './workflows/2_classification'
include { ALIGNMENT }          from './workflows/3_alignment'
include { VIRAL_ALIGNMENT }    from './workflows/5_viral_alignment'
include { QUANTIFICATION }     from './workflows/4_quantification'
include { MULTIQC }            from './modules/multiqc'
include { BWA_INDEX_VIRAL }    from './modules/bwa_index_viral'
include { SALMON_INDEX_VIRAL } from './modules/salmon_index_viral'

workflow NEGEDIA {

    // -------------------------------------------------
    // 1. Lettura CSV e creazione del channel dei samples
    // -------------------------------------------------
    samples = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            def (r1, r2) = row.input_path.split(';')
            tuple(
                row.sample_name,      // sample_id
                row.project_name,     // project_name
                row.virus_to_detect,  // virus
                file(r1),
                file(r2)
            )
        }

    samples.view()
    
    // Nuovo canale: ottiene il nome del progetto in modo che venga emesso una sola volta
    project_name_ch = samples
        .map { it[1] }      // Prende il nome del progetto
        .first()            // Prende il primo elemento e si ferma

    // -------------------------------------------------
    // 2. Pre-processing reads
    // -------------------------------------------------
    preprocessing_out = PREPROCESSING(samples)

    // -------------------------------------------------
    // 3. Creazione indici virali
    // -------------------------------------------------
    viral_bwa_index = BWA_INDEX_VIRAL(params.viral_fa, project_name_ch)
    viral_salmon_index = SALMON_INDEX_VIRAL(params.viral_fa, project_name_ch)

    // -------------------------------------------------
    // 4. Allineamento umano (STAR)
    // -------------------------------------------------
    alignment_out = ALIGNMENT(preprocessing_out.trimmed)

    // -------------------------------------------------
    // 5. Estrazione reads non mappate da STAR
    // -------------------------------------------------
    unmapped_reads_from_star = alignment_out.star_results
        .map { sid, proj, virus, bam, r1, r2, log ->
                tuple(sid, proj, virus, r1, r2)
    }

    // -------------------------------------------------
    // 6. Allineamento virale (BWA-MEM2)
    // -------------------------------------------------
    viral_alignment_out = VIRAL_ALIGNMENT(unmapped_reads_from_star, viral_bwa_index)

    // -------------------------------------------------
    // 7. Classificazione Kraken2
    // -------------------------------------------------
    classification_out = CLASSIFICATION(preprocessing_out.trimmed)

    // -------------------------------------------------
    // 8. Quantificazione espressione virale (Salmon)
    // -------------------------------------------------
    quantification_out = QUANTIFICATION(unmapped_reads_from_star, viral_salmon_index)

    // -------------------------------------------------
    // 9. Raccolta file QC per MultiQC
    // -------------------------------------------------
    // SOLUZIONE CORRETTA: Rielaborazione del canale all_qc_files
    all_qc_files = preprocessing_out.trimmed_qc_html
          .merge(preprocessing_out.trimmed_qc_zip)
          .merge(classification_out.kraken_reports.map { it[4] }.filter { it instanceof Path || it instanceof File })
          .merge(classification_out.kraken_reports.map { it[5] }.filter { it instanceof Path || it instanceof File })
          .merge(classification_out.kraken_reports.map { it[6] }.filter { it instanceof Path || it instanceof File })
          .merge(classification_out.kraken_reports.map { it[7] }.filter { it instanceof Path || it instanceof File })
          .merge(classification_out.kraken_reports.map { it[8] }.filter { it instanceof Path || it instanceof File })
          .merge(alignment_out.star_results.map { it[5] }.filter { it instanceof Path || it instanceof File })
          .merge(quantification_out.quant_res.map { it[2] }.filter { it instanceof Path || it instanceof File })

    multiqc_input = all_qc_files.map { file -> tuple(file) }

    // -------------------------------------------------
    // 11. Log finale
    // -------------------------------------------------
    log.info """
    =========================================
        INF-ACT PROJECT PIPELINE (NEGEDIA)
    =========================================
    Project name        : ${project_name_ch}
    Samplesheet         : ${params.input}
    Output directory    : ${params.outdir}
    Viral genome FASTA  : ${params.viral_fa}
    Human genome index  : ${params.star_idx}
    Kraken2 DB          : ${params.kraken_db}
    =========================================
    """
}

workflow {
    NEGEDIA()
}
