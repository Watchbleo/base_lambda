# base_lambda

Template repo for single-purpose AWS Lambda functions (AWS SAM, Zip-packaged),
deployed per environment (dev / qa / prod) by Jenkins via a plain bash script.
Fork it, then follow **INSTRUCTIONS.txt**.

```
function/app.py, requirements.txt   the Lambda (one function per repo)
template.yml                        SAM app (Environment parameter, Mappings)
samconfig.toml                      one stanza per env, no default stanza
deploy.sh                           ./deploy.sh <dev|qa|prod>
.pre-commit-config.yaml             ruff, detect-secrets, hygiene, sam validate --lint
.jenkins/Jenkinsfile.quality-checks PR quality gate
.jenkins/lambda/Jenkinsfile.<name>  shared deploy pipeline (one job per env)
```
