# postgres-diag-queries

Run diag queries periodically via Cronjob to a postgres database and store them in S3

## Installation

```
oc process -f openshift/cronjob.yaml | oc apply -f -
```

### Configuration

The template expects a configmap (configurable via `QUERIES_CONFIGMAP` parameter), e.g.

```
apiVersion: v1
kind: ConfigMap
name: postgres-diag-queries
data:
  serviceslo.sql: |
    select * from serviceslo;
  severity.sql: |
    select * from severity;
```

### Database access

The template expects a secret (configurable via `POSTGRES_DB_SECRET_NAME`) with the following data structure:

```yaml
apiVersion: v1
kind: Secret
name: postgres-diag-queries-rds
data:
  db.host: <DB_HOST>
  db.name: <DB_NAME>
  db.password: <DB_PASSWORD>
  db.port: <DB_PORT>
  db.user: <DB_USER>
```

### S3 access

The template expects a secret (configurable via `AWS_S3_SECRET_NAME`) with the following data structure:

```yaml
apiVersion: v1
kind: Secret
name: postgres-diag-queries-s3
data:
  aws_access_key_id: <key_id>
  aws_region: <region>
  aws_secret_access_key: <region>
  bucket: <bucket>
```
