pipeline {
    agent {
        docker {
            image 'danischm/nac:0.1.4'
            label 'digidev'
        }
    }

    parameters {
        booleanParam(name: 'NDI_PCV', defaultValue: false, description: 'Enable NDI Pre-Change Validation')
    }

    environment {
        TF_TOKEN_app_terraform_io = credentials('TF_TOKEN_app_terraform_io')
        ACI_URL = credentials('ACI_URL')
        ACI_USERNAME = credentials('ACI_USERNAME')
        ACI_PASSWORD = credentials('ACI_PASSWORD')
        WEBEX_TOKEN = credentials('WEBEX_TOKEN')
        WEBEX_ROOM_ID = 'Y2lzY29zcGFyazovL3VzL1JPT00vNTFmMGNmODAtYjI0My0xMWU5LTljZjUtNWY0NGQ2ZTlmYWY0'
        GITHUB_TOKEN = credentials('GITHUB_TOKEN')
        REPO = env.GIT_URL.replaceFirst(/^.*?(?::\/\/.*?\/|:)(.*).git$/, '$1')
        GIT_COMMIT_MESSAGE = "${sh(returnStdout: true, script: 'git log -1 --pretty=%B ${GIT_COMMIT}').trim()}"
        GIT_COMMIT_AUTHOR = "${sh(returnStdout: true, script: 'git show -s --pretty=%an').trim()}"
        GIT_EVENT = "${(env.CHANGE_ID != null) ? 'Pull Request' : 'Push'}"
    }

    options {
        disableConcurrentBuilds()
    }

    stages {
        stage('Setup') {
            steps {
                sh 'terraform init -input=false'
            }
        }
        stage('Validate') {
            steps {
                sh 'set -o pipefail && terraform fmt -check |& tee fmt_output.txt'
                sh 'set -o pipefail && iac-validate ./data/ |& tee validate_output.txt'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -out=plan.tfplan -input=false'
                sh 'terraform show -no-color plan.tfplan > plan.txt'
                sh 'terraform show -json plan.tfplan > plan.json'
                sh 'python3 .ci/github-comment.py'
                archiveArtifacts 'plan.*'
            }
        }
        stage('NDI Pre-Change Validation') {
            when {
                changeRequest target: 'master'
                expression { return params.NDI_PCV }
            }
            environment {
                PCV_HOSTNAME_IP = credentials('PCV_HOSTNAME_IP')
                PCV_USERNAME = credentials('PCV_USERNAME')
                PCV_PASSWORD = credentials('PCV_PASSWORD')
                PCV_GROUP = credentials('PCV_GROUP')
                PCV_NAME = "Jenkins Build ${BUILD_DISPLAY_NAME} PR #${CHANGE_ID}"
            }
            steps {
                sh 'nexus-pcv --nac-tf-plan plan.json --output-summary ndi_pcv_output.txt --output-url ndi_url.txt'
            }
        }
        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                sh 'terraform apply -input=false -auto-approve plan.tfplan'
            }
        }
        stage('Test') {
            when {
                branch 'master'
            }
            parallel {
                stage('Test Idempotency') {
                    steps {
                        sh 'terraform plan -input=false -detailed-exitcode'
                    }
                }
                stage('Test Integration') {
                    steps {
                        sh 'set -o pipefail && iac-test -d ./data -d ./defaults.yaml -t ./tests/templates -f ./tests/filters -o ./tests/results/aci |& tee test_output.txt'
                    }
                    post {
                        always {
                            archiveArtifacts 'tests/results/aci/log.html, tests/results/aci/output.xml, tests/results/aci/report.html, tests/results/aci/xunit.xml'
                            junit 'tests/results/aci/xunit.xml'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            sh "BUILD_STATUS=${currentBuild.currentResult} python3 .ci/webex-notification-jenkins.py"
            sh 'rm -rf plan.* *.txt tests/results'
        }
    }
}
