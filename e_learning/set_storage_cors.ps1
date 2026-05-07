# Run this after authenticating with gcloud.
# If you have not authenticated yet, run:
#   gcloud auth login

$bucket = 'gs://e-learning-platform-fd30c.firebasestorage.app'
$corsFile = Join-Path $PSScriptRoot 'cors.json'

gsutil cors set $corsFile $bucket

gsutil cors get $bucket
