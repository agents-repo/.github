---
marp: true
theme: agents-repo
paginate: true
---

<!-- _class: title -->

# Contributing workflow

Issue → branch → draft PR → validate → human ready → merge

agents-repo organization

---

# Required workflow

Every task in an active development repository follows this lifecycle.

1. Open a tracking issue
2. Create a branch from latest `main`
3. Push and open a **draft** pull request **before** implementation
4. Implement and validate on that branch
5. A **human** marks the PR ready for review
6. A **human maintainer** merges to `main`

---

# 1. Issue first

- Child repos: use the matching issue form
- This `.github` repo: plain issues are OK
- Registry **package** submissions MAY omit an issue (exception)

Use the number GitHub assigns after submit. Do not edit the issue body just to
insert the number.

---

# 2. Branch naming

`<prefix>/<issue-number>-<slug>`

| Work | Prefix |
| --- | --- |
| Bug | `fix/` |
| Spec (`specs/`) | `spec/` |
| Feature | `feat/` |
| Task / chore | `chore/` |
| Docs (non-spec) | `docs/` |
| Registry package | `package/` |

`spec/` is not used in registry-proxy. Prefix categorizes work; commit prefix
drives release bumps.

---

# 3. Draft PR before implementation

- `gh pr create --draft`
- Target `main`
- `## Related Issues` includes `Closes #<issue-number>`
- GitHub cannot open a PR when head equals base — push a scaffold commit first

Do not open a non-draft PR at creation time.

---

# 4. Implement and validate

Push commits to the **task branch** only.

Run that repository’s validation commands (see its `CONTRIBUTING` and agent
instructions). Do not copy another repo’s npm scripts blindly.

Agents complete work on the branch, then **hand off**.

---

# 5–6. Ready and merge are human

- Agents and automation **MUST NOT** mark PRs ready for review
- Agents **MUST NOT** merge to `main` or push to `main`
- Integration to `main` is pull-request-only, after review

---

# Which repository?

| Work | Repo |
| --- | --- |
| Specs, packages, ZIPs | registry |
| Site UI, docs pages | webapp |
| `npx agents-repo` | cli |
| Cloudflare Worker proxy | registry-proxy |
| Org defaults, CONTRIBUTING | .github |

`agents-repo.github.io` is the webapp Pages target, not a dev repo.

---

# Per-repo CONTRIBUTING

After this org guide, follow the repo you are changing:

- `registry/.github/CONTRIBUTING.md`
- `webapp/.github/CONTRIBUTING.md`
- `cli/.github/CONTRIBUTING.md`
- `registry-proxy/.github/CONTRIBUTING.md`

Those guides own setup, validation matrices, and issue forms.

---

# Pre-ready agent handoff

While the PR is still a **draft**:

1. Follow the plan; do not expand scope
2. Read exemplar files in the same area
3. Run validation; record evidence on the draft PR
4. Self-review
5. Do **not** mark ready for review

---

# Security and hotfixes

- Vulnerabilities: private reporting (`SECURITY.md`), not public issues
- Emergency hotfix: `fix/<issue>-<slug>` with maintainer approval — still a PR
- Package PRs squash with `feat(package):` / `fix(package):`

---

# Links

- Org CONTRIBUTING: `CONTRIBUTING.md` in this repository
- Branch prefix table: same file
- Ecosystem orientation: `docs/ecosystem.md` and the ecosystem PDF
- Site: [https://agents-repo.org/docs](https://agents-repo.org/docs)

---

<!-- _class: closing -->

# Remember

Issue → `docs/` (or other prefix) branch → **draft** PR → validate →
**human** ready → **human** merge.
