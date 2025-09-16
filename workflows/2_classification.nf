/* include { KRAKEN2 } from '../modules/kraken2'

workflow CLASSIFICATION {
    take: trimmed_reads

    main:
    // Esegue Kraken2 su tutti i campioni
    kraken_out = KRAKEN2(trimmed_reads)

    emit:
    // Emette i report di Kraken2 per MultiQC
    kraken_reports = kraken_out
} */

include { KRAKEN2 } from '../modules/kraken2'

workflow CLASSIFICATION {
    take:
    trimmed // avevo lasciato nomenclatura vecchia

    main:
    // Carica il database di Kraken2
    def kraken2_db_channel = Channel.fromPath(params.kraken_db)

    // Prepara l'input per Kraken2
    kraken_input = trimmed.map { sample_id, project_name, virus, r1, r2 ->
        tuple(sample_id, project_name, virus, r1, r2)
    }

    // Lancia Kraken2
    kraken_out = KRAKEN2(kraken_input, kraken2_db_channel)

    emit:
    kraken_reports = kraken_out
}
