process MMSEQS_COLABFOLDSEARCH {
    tag "$seq_name"
    label 'high'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://athbaltzis/colabfold_proteinfold:v0.9' :
        'athbaltzis/colabfold_proteinfold:v0.9' }"

    input:
    tuple val(seq_name), path(fasta)
    path ('db/params')
    path uniref30
    path colabfold_db
    val db_load_mode

    output:
    tuple val(seq_name), path("${seq_name.sequence}.a3m"), emit: a3m
    path "versions.yml" , emit: versions


    script:
    def args = task.ext.args ?: ''
    def VERSION = '1.2.0'

    // mmseqs touchdb ${db}/uniref30_2103_db --threads $task.cpus
    // mmseqs touchdb ${db}/colabfold_envdb_202108_db --threads $task.cpus
    """
    ln -r -s $uniref30/* ./db
    ln -r -s $colabfold_db/* ./db
    /colabfold_batch/colabfold-conda/bin/colabfold_search --db-load-mode ${db_load_mode} --threads $task.cpus ${fasta} ./db "result/"
    cp result/0.a3m ${seq_name.sequence}.a3m

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        colabfold_search: $VERSION
    END_VERSIONS
    """

    stub:
    """
    touch ${seq_name.sequence}.a3m
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        colabfold_search: $VERSION
    END_VERSIONS
    """
}
