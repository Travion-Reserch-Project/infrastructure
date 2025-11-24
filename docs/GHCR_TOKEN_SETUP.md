# Setup GHCR_TOKEN for Private Package Access

## Create Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   https://github.com/settings/tokens

2. Click "Generate new token" → "Generate new token (classic)"

3. Configure the token:

   - **Name**: `GHCR Package Access for Deployments`
   - **Expiration**: Choose appropriate duration (90 days, 1 year, or no expiration)
   - **Scopes**: Select the following:
     - ✅ `read:packages` - Download packages from GitHub Package Registry
     - ✅ `write:packages` - Upload packages to GitHub Package Registry (optional, if you build from this workflow)

4. Click "Generate token"

5. **Copy the token immediately** (you won't be able to see it again)

## Add Token to Organization Secrets

1. Go to Organization Settings → Secrets and variables → Actions
   https://github.com/organizations/Travion-Reserch-Project/settings/secrets/actions

2. Click "New organization secret"

3. Configure:

   - **Name**: `GHCR_TOKEN`
   - **Secret**: Paste the PAT you just created
   - **Repository access**: Select "All repositories" or choose specific repos

4. Click "Add secret"

## Verify Setup

After adding the secret, the deployment workflow will use it to authenticate with GHCR and pull private container images.

Test by:

1. Triggering a deployment from backend repo
2. Or manually running the infrastructure deployment workflow

The deployment should now successfully pull private images from `ghcr.io/travion-reserch-project/*`

## Alternative: Make Packages Public

If you don't need packages to be private, you can make them public instead:

1. Go to the package page:
   https://github.com/orgs/Travion-Reserch-Project/packages/container/travion-backend/settings

2. Scroll to "Danger Zone"

3. Click "Change visibility" → "Public"

This eliminates the need for authentication when pulling images.
