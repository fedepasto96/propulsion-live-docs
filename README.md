# E4 Battery Project — Planning Documents

Internal HTML documentation for the E4 Battery Project, auto-published via GitHub Pages.

**Live site:** [https://fedepasto-96.github.io/e4-battery-planning-docs/](https://fedepasto-96.github.io/e4-battery-planning-docs/)

## Structure

| Folder | Contents |
|--------|----------|
| `Charger Suppliers/` | Supplier scouting, rankings, cost comparisons, outreach templates |
| `Pack Assemblers/` | Assembler scouting, cost comparisons, outreach templates |
| `Reports/` | Budget reports, Gantt charts, supply chain diagrams, risk updates |
| `project updates/` | Risk overview and mitigation slides |
| `Supplier Engagement/` | Lab and visit questionnaires |
| `Cost Evaluation Material/` | Cost estimation guidelines |
| `Regulatory/` | Export rules and regulations |

## Sync from Shared Drive

HTML files originate from the Google Shared Drive project folder. To sync changes:

### Option A — PowerShell (recommended on Windows)
```powershell
cd ~\e4-battery-planning-docs
.\sync-html.ps1           # Sync and push
.\sync-html.ps1 -DryRun   # Preview changes without pushing
```

### Option B — Bash (Git Bash / WSL)
```bash
cd ~/e4-battery-planning-docs
./sync-html.sh             # Sync and push
./sync-html.sh --dry-run   # Preview changes without pushing
```

### Option C — Automatic (Cursor IDE)
A Cursor rule is configured so that any time an HTML file is created or modified in the workspace, the AI assistant will automatically sync it to this repo and push.
