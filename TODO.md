# TODO: Template Customization Checklist

After cloning this template repository, complete these steps to customize it for your project.

## Repository & Project Info

- [ ] Update `sfdx-project.json`:
  - [ ] Change package name from "Package Name Lib" to your package name
  - [ ] Update package version and versionName as needed
- [ ] Update `package.json`:
  - [ ] Change `name` from `salesforce-repo` to your project name
  - [ ] Update `description` to describe your project

## Documentation (website/)

### Update VitePress Configuration

- [ ] Update `website/.vitepress/config.mts`:
  - [ ] Change `title` from "Salesforce Template" to your project name
  - [ ] Update `description` to describe your project
  - [ ] Update `base` URL to match your repo name (e.g., `/your-repo-name/`)
  - [ ] Update `sitemap.hostname` to your documentation URL
  - [ ] **Configure Google Tag Manager** (currently commented out):
    - [ ] Get your GTM ID from Google Tag Manager
    - [ ] Uncomment GTM script tags in `head` section
    - [ ] Replace `YOUR-GTM-ID` with your actual GTM ID
  - [ ] Update `socialLinks` GitHub URL to your repository

## GitHub Actions & CI/CD

### Enable GitHub Pages

- [ ] Go to repository Settings → Pages
- [ ] Set Source to "GitHub Actions"
- [ ] Save settings

### Configure GitHub Secrets

- [ ] For Private repositories only:
  - [ ] Add `SFDX_AUTH_URL_DEVHUB` secret
  - [ ] Add `CODECOV_TOKEN` secret

## Branding & Assets

- [ ] Add project logo
- [ ] Update LICENSE file if needed (currently MIT)

## Optional Enhancements

### Repository Configuration

- [ ] Configure Dependabot for dependency updates:
  - Create `.github/dependabot.yml`
- [ ] Add CODEOWNERS file for automatic PR review assignments:
  - Create `.github/CODEOWNERS`
- [ ] Set up branch protection rules:
  - Go to Settings → Branches → Add rule
  - Protect `main` branch
  - Require PR reviews
  - Require status checks

### Issue & PR Templates

- [ ] Update issue templates `.github/ISSUE_TEMPLATE/feature_request.md`
- [ ] update pull request template `.github/PULL_REQUEST_TEMPLATE.md`

### Additional Documentation

- [ ] Add CHANGELOG.md for version tracking

### GitHub Configuration

- **Settings → Pages**: Enable GitHub Actions deployment
- **Settings → Secrets**: Add `SFDX_AUTH_URL_DEVHUB` and `CODECOV_TOKEN`
- **Settings → Branches**: Set up branch protection (optional but recommended)

**Note:** Once you've completed this checklist, delete this file and commit your changes.
