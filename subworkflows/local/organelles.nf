include { MITOHIFI_FINDMITOREFERENCE                    } from '../../modules/nf-core/mitohifi/findmitoreference/main'
include { MITOHIFI_MITOHIFI as MITOHIFI_MITOHIFI_READS  } from '../../modules/nf-core/mitohifi/mitohifi/main'
include { MITOHIFI_MITOHIFI as MITOHIFI_MITOHIFI_ASM    } from '../../modules/nf-core/mitohifi/mitohifi/main'
include { CAT_CAT as CAT_CAT_MITOHIFI                   } from "../../modules/nf-core/cat/cat/main"

workflow ORGANELLES {
    take:
    hifi_reads  // channel: [ val(meta), [datafile]  ]
    contigs     // channel: [ val(meta), datafile ] 
    mito_info   // channel: [ val(species), val(min_length), val(code), val(email) ]

    main:
    ch_versions = Channel.empty()

    mito_info.map{ species, min_length, code, email -> species}.set{species}
    mito_info.map{ species, min_length, code, email -> min_length}.set{min_length}
    mito_info.map{ species, min_length, code, email -> code}.set{code}
    mito_info.map{ species, min_length, code, email -> email}.set{email}
    MITOHIFI_FINDMITOREFERENCE(species, email, min_length)

    if ( hifi_reads ) {
        CAT_CAT_MITOHIFI(hifi_reads)
        MITOHIFI_MITOHIFI_READS( CAT_CAT_MITOHIFI.out.file_out.map{meta, hifi -> [meta, hifi, []]}, 
                        MITOHIFI_FINDMITOREFERENCE.out.fasta,
                        MITOHIFI_FINDMITOREFERENCE.out.gb,
                        code)    
        mitohifi_reads = MITOHIFI_MITOHIFI_READS.out
    }
    if ( contigs ) {
        MITOHIFI_MITOHIFI_ASM( contigs.map{meta, contigs -> [meta, [], contigs]}, 
                        MITOHIFI_FINDMITOREFERENCE.out.fasta,
                        MITOHIFI_FINDMITOREFERENCE.out.gb,
                        code)    
        mitohifi_asm = MITOHIFI_MITOHIFI_ASM.out

    }
    
    emit:

    versions = ch_versions
}
