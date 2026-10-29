# Terraform Bootstrap

Creates the S3 bucket used to store Terraform state for the capstone.

Implemented bucket configuration:

- Block all public access.
- Enable versioning.
- Enable server-side encryption.
- Require HTTPS.
- Support S3-native Terraform state locking.

This bootstrap runs locally before Jenkins is available.

Bootstrap state must be preserved securely and must not be committed to Git.
