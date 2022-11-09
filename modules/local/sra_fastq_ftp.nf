
process SRA_FASTQ_FTP {
    tag "$meta.id"
    label 'process_low'
    label 'error_retry'

    conda (params.enable_conda ? '/dss/dsshome1/lxc03/ru83ced/.nextflow/assets/nf-core/fetchngs/conf/sratools.yaml' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sra-tools:2.11.0--pl5321ha49a11a_3' :
        'quay.io/biocontainers/sra-tools:2.11.0--pl5321ha49a11a_3' }"

    input:
    tuple val(meta), val(fastq)

    output:
    tuple val(meta), path("*fastq.gz"), emit: fastq
    tuple val(meta), path("*md5")     , emit: md5
    path "versions.yml"               , emit: versions

    script:
    def args = task.ext.args ?: ''
    if (meta.single_end) {
        """
        curl \\
            $args \\
            -L ${fastq[0]} \\
            -o ${meta.id}.fastq.gz

        echo "${meta.md5_1}  ${meta.id}.fastq.gz" > ${meta.id}.fastq.gz.md5
        md5sum -c ${meta.id}.fastq.gz.md5

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            curl: \$(echo \$(curl --version | head -n 1 | sed 's/^curl //; s/ .*\$//'))
        END_VERSIONS
        """
    } else {
        """
        curl \\
            $args \\
            -L ${fastq[0]} \\
            -o ${meta.id}_1.fastq.gz

        echo "${meta.md5_1}  ${meta.id}_1.fastq.gz" > ${meta.id}_1.fastq.gz.md5
        md5sum -c ${meta.id}_1.fastq.gz.md5

        curl \\
            $args \\
            -L ${fastq[1]} \\
            -o ${meta.id}_2.fastq.gz

        echo "${meta.md5_2}  ${meta.id}_2.fastq.gz" > ${meta.id}_2.fastq.gz.md5
        md5sum -c ${meta.id}_2.fastq.gz.md5

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            curl: \$(echo \$(curl --version | head -n 1 | sed 's/^curl //; s/ .*\$//'))
        END_VERSIONS
        """
    }
}
