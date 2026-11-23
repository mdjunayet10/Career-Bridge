#!/usr/bin/env python3
"""Fast repository checks that do not require Flutter or Firebase CLIs."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FRONTEND = ROOT / "frontend"
BACKEND = ROOT / "backend"

errors: list[str] = []
warnings: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


def warn(message: str) -> None:
    warnings.append(message)


def require(path: Path) -> None:
    if not path.exists():
        fail(f"Missing required path: {path.relative_to(ROOT)}")


required_paths = [
    FRONTEND / "pubspec.yaml",
    FRONTEND / "lib/main.dart",
    FRONTEND / "lib/app/app.dart",
    FRONTEND / "lib/features/public_portal/controllers/public_portal_controller.dart",
    FRONTEND / "lib/features/companies/controllers/company_logo_registry.dart",
    FRONTEND / "lib/shared/widgets/company_logo.dart",
    FRONTEND / "lib/features/public_portal/data/repositories/firebase_public_portal_repository.dart",
    FRONTEND / "lib/app/router/app_router.dart",
    ROOT / "scripts/verify_release.sh",
    FRONTEND / "assets/logos/career_bridge_selected_logo.png",
    FRONTEND / "assets/logos/career_bridge_logo_icon.png",
    FRONTEND / "config/demo.json",
    FRONTEND / "config/firebase.example.json",
    BACKEND / "firebase/firestore.rules",
    BACKEND / "firebase/firestore.indexes.json",
    BACKEND / "firebase/firebase.json",
]
for item in required_paths:
    require(item)

# JSON validity and duplicate seed IDs.
for path in ROOT.rglob("*.json"):
    if path.name == "firebase.local.json":
        warn("frontend/config/firebase.local.json is present for this local deploy-ready copy; keep it out of public commits")
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001
        fail(f"Invalid JSON: {path.relative_to(ROOT)} ({exc})")
        continue

    if path.parent.name == "seed_data" and isinstance(value, list):
        ids = [entry.get("id") for entry in value if isinstance(entry, dict)]
        actual = [item for item in ids if item is not None]
        if len(actual) != len(set(actual)):
            fail(f"Duplicate seed IDs: {path.relative_to(ROOT)}")

# Relative Dart imports must resolve.
import_pattern = re.compile(r"^import\s+['\"]([^'\"]+)['\"]", re.MULTILINE)
for path in FRONTEND.rglob("*.dart"):
    source = path.read_text(encoding="utf-8")
    for target in import_pattern.findall(source):
        if target.startswith("package:career_bridge/"):
            relative = target.removeprefix("package:career_bridge/")
            resolved = FRONTEND / "lib" / relative
            if not resolved.exists():
                fail(
                    f"Broken Career Bridge package import in "
                    f"{path.relative_to(ROOT)}: {target}"
                )
            continue
        if target.startswith(("package:", "dart:")):
            continue
        resolved = (path.parent / target).resolve()
        if not resolved.exists():
            fail(
                f"Broken relative import in {path.relative_to(ROOT)}: {target}"
            )

# Lightweight delimiter balance. Flutter analyze remains authoritative.
def strip_strings_and_comments(text: str) -> str:
    # Replace Dart strings/comments with spaces while preserving newlines.
    output: list[str] = []
    index = 0
    length = len(text)
    state = "code"
    quote = ""
    triple = False

    while index < length:
        char = text[index]
        next_char = text[index + 1] if index + 1 < length else ""
        next_three = text[index : index + 3]

        if state == "code":
            if char == "/" and next_char == "/":
                output.extend((" ", " "))
                index += 2
                state = "line_comment"
                continue
            if char == "/" and next_char == "*":
                output.extend((" ", " "))
                index += 2
                state = "block_comment"
                continue
            if next_three == "'''" or next_three == chr(34) * 3:
                quote = next_three[0]
                triple = True
                output.extend((" ", " ", " "))
                index += 3
                state = "string"
                continue
            if char == "'" or char == chr(34):
                quote = char
                triple = False
                output.append(" ")
                index += 1
                state = "string"
                continue
            output.append(char)
            index += 1
            continue

        if state == "line_comment":
            if char == "\n":
                output.append("\n")
                state = "code"
            else:
                output.append(" ")
            index += 1
            continue

        if state == "block_comment":
            if char == "*" and next_char == "/":
                output.extend((" ", " "))
                index += 2
                state = "code"
            else:
                output.append("\n" if char == "\n" else " ")
                index += 1
            continue

        if state == "string":
            if char == "\\":
                output.append(" ")
                if index + 1 < length:
                    output.append("\n" if text[index + 1] == "\n" else " ")
                index += 2
                continue
            if triple and text[index : index + 3] == quote * 3:
                output.extend((" ", " ", " "))
                index += 3
                state = "code"
                continue
            if not triple and char == quote:
                output.append(" ")
                index += 1
                state = "code"
                continue
            output.append("\n" if char == "\n" else " ")
            index += 1
            continue

    return "".join(output)

pairs = {"(": ")", "[": "]", "{": "}"}
for path in FRONTEND.rglob("*.dart"):
    text = strip_strings_and_comments(path.read_text(encoding="utf-8"))
    stack: list[str] = []
    for char in text:
        if char in pairs:
            stack.append(char)
        elif char in pairs.values():
            if not stack or pairs[stack.pop()] != char:
                fail(f"Unbalanced delimiter in {path.relative_to(ROOT)}")
                break
    else:
        if stack:
            fail(f"Unbalanced delimiter in {path.relative_to(ROOT)}")

# Job/company demo IDs must stay aligned.
company_text = (FRONTEND / "lib/features/companies/data/companies_demo_data.dart").read_text()
job_text = (FRONTEND / "lib/features/jobs/data/jobs_demo_data.dart").read_text()
company_ids = set(re.findall(r"CompanyModel\(\s*id:\s*'([^']+)'", company_text))
job_company_ids = set(re.findall(r"companyId:\s*'([^']+)'", job_text))
missing_companies = sorted(job_company_ids - company_ids)
if missing_companies:
    fail(f"Demo jobs reference missing companies: {', '.join(missing_companies)}")

job_ids = re.findall(r"JobModel\(\s*id:\s*'([^']+)'", job_text)
if len(job_ids) != len(set(job_ids)):
    fail("Duplicate JobModel IDs in jobs_demo_data.dart")

# Manifest icon references must exist.
manifest_path = FRONTEND / "web/manifest.json"
if manifest_path.exists():
    manifest = json.loads(manifest_path.read_text())
    for icon in manifest.get("icons", []):
        src = icon.get("src")
        if src and not (FRONTEND / "web" / src).exists():
            fail(f"Web manifest icon is missing: frontend/web/{src}")

# Architecture constraints.
pubspec = (FRONTEND / "pubspec.yaml").read_text()
for forbidden in ("firebase_storage", "cloud_functions"):
    if re.search(rf"^\s*{re.escape(forbidden)}\s*:", pubspec, re.MULTILINE):
        fail(f"Forbidden billing-related dependency found: {forbidden}")

# Cloud Functions were introduced for notifications after the original 1.5.0
# architecture check. Keep them, but require their package manifest.
if (BACKEND / "functions").exists() and not (BACKEND / "functions/package.json").exists():
    fail("backend/functions is missing package.json")

rules = (BACKEND / "firebase/firestore.rules").read_text()
if rules.count("{") != rules.count("}"):
    fail("Firestore Rules braces are unbalanced")


# Live public portal must not regress to direct demo-data imports in UI files.
public_ui_roots = [
    FRONTEND / "lib/features/public_portal/presentation",
    FRONTEND / "lib/features/jobs/presentation",
    FRONTEND / "lib/features/companies/presentation",
]
for ui_root in public_ui_roots:
    for path in ui_root.rglob("*.dart"):
        source = path.read_text(encoding="utf-8")
        if any(token in source for token in ("JobsDemoData", "CompaniesDemoData", "LandingMockData")):
            fail(
                "Public UI bypasses PublicPortalController in "
                f"{path.relative_to(ROOT)}"
            )

application_source = (
    FRONTEND / "lib/features/applications/data/models/application_model.dart"
).read_text(encoding="utf-8")
for required_snapshot_field in (
    "jobTitle",
    "companyName",
    "jobLocation",
    "jobEmploymentType",
    "jobSalaryLabel",
):
    if required_snapshot_field not in application_source:
        fail(f"Application job snapshot field is missing: {required_snapshot_field}")


# Batch 3 company-logo architecture invariants.
logo_registry_source = (
    FRONTEND / "lib/features/companies/controllers/company_logo_registry.dart"
).read_text(encoding="utf-8")
company_logo_widget_source = (
    FRONTEND / "lib/shared/widgets/company_logo.dart"
).read_text(encoding="utf-8")
public_portal_source = (
    FRONTEND / "lib/features/public_portal/controllers/public_portal_controller.dart"
).read_text(encoding="utf-8")
employer_workspace_source = (
    FRONTEND / "lib/features/employer/controllers/employer_workspace_controller.dart"
).read_text(encoding="utf-8")

if "class CompanyLogoRegistry" not in logo_registry_source:
    fail("CompanyLogoRegistry singleton is missing")
if "CompanyLogoRegistry.instance" not in company_logo_widget_source:
    fail("CompanyLogo widget is not listening to the shared company-logo registry")
if "replaceFromCompanies" not in public_portal_source:
    fail("Public portal does not refresh the shared company-logo registry")
if "CompanyLogoRegistry.instance" not in employer_workspace_source:
    fail("Employer workspace does not publish uploaded company-logo changes")
if "companyId" not in application_source:
    fail("Application snapshots do not retain companyId for shared-logo lookup")

for forbidden_logo_field in ("companyInitial", "companyLogoFileId"):
    occurrences = []
    for root in (FRONTEND / "lib", BACKEND / "firestore/schemas"):
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix in {".dart", ".md", ".json"}:
                if forbidden_logo_field in path.read_text(encoding="utf-8"):
                    occurrences.append(str(path.relative_to(ROOT)))
    if occurrences:
        fail(
            f"Deprecated per-job/application logo field {forbidden_logo_field} remains in: "
            + ", ".join(occurrences)
        )

# Final release hardening checks.
file_controller_source = (
    FRONTEND / "lib/features/file_storage/controllers/file_storage_controller.dart"
).read_text(encoding="utf-8")
if "_repositoryUid" not in file_controller_source or "_memoryCache.clear()" not in file_controller_source:
    fail("File cache is not isolated across authenticated user sessions")
download_start = file_controller_source.find("Future<Uint8List> download")
download_end = file_controller_source.find("Future<void> sharePdf", download_start)
download_source = file_controller_source[download_start:download_end]
if download_source.find("_resolveRepository()") > download_source.find("_memoryCache[fileId]"):
    fail("File download consults memory before validating the active session")

if "resource.data.status in [" not in rules or "request.resource.data.status == 'withdrawn'" not in rules:
    fail("Application withdrawal rules do not protect terminal application states")

verify_script = ROOT / "scripts/verify_release.sh"
if verify_script.exists() and not (verify_script.stat().st_mode & 0o111):
    fail("scripts/verify_release.sh must be executable")

# Version expectation for this milestone.
version_match = re.search(r"^version:\s*(.+)$", pubspec, re.MULTILINE)
if not version_match:
    fail("pubspec.yaml has no version")
elif not re.fullmatch(r"\d+\.\d+\.\d+\+\d+", version_match.group(1)):
    fail(f"Invalid Flutter package version: {version_match.group(1)}")

# UI polish assets and removed public sections.
company_logo_dir = FRONTEND / "assets/company_logos"
if not company_logo_dir.exists():
    fail("Bundled company logo directory is missing")
else:
    for company_id in sorted(company_ids):
        if not (company_logo_dir / f"{company_id}.png").exists():
            # Logo widgets intentionally show a neutral fallback for fictional
            # companies without a logo, so lack of an asset isn't an error.
            warn(f"Company {company_id} uses the generic logo fallback")

if "career-resources" in (FRONTEND / "lib/app/router/app_routes.dart").read_text():
    fail("Removed Career Resources route is still present")

company_logo_source = (
    FRONTEND / "lib/shared/widgets/company_logo.dart"
).read_text(encoding="utf-8")
if "_InitialFallback" in company_logo_source or "substring(0, 1)" in company_logo_source:
    fail("Company logo fallback still renders company-name text")

print(f"Checked {len(list(FRONTEND.rglob('*.dart')))} Dart files.")
for message in warnings:
    print(f"WARNING: {message}")
for message in errors:
    print(f"ERROR: {message}")

if errors:
    print(f"Project check failed with {len(errors)} error(s).")
    sys.exit(1)

print("Project check passed.")
