#!/usr/bin/env python3
"""
Split 8 D365 Finance Ballerina modules into independent packages.
Run from the repo root: python3 scripts/generate_packages.py
"""
import os
import re
import shutil
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
BAL_DIR = BASE_DIR / "ballerina"
BUILD_CFG_DIR = BASE_DIR / "build-config" / "resources"

# ---------------------------------------------------------------------------
# Package mapping: new_name -> {source, entities, display, area, keywords}
# ---------------------------------------------------------------------------
PACKAGES = {
    # ---- From asset ----
    "fixedasset": {
        "source": "asset",
        "entities": ["AssetLendings", "AssetSortings", "FixedAssetValueModels", "FixedAssets",
                     "FixedAssetsV2", "LeasingGroups", "ParentLeases", "RAssetGroups",
                     "RAssetLedgers", "RAssetTables", "RAssetUses"],
        "display": "Fixed Asset",
        "area": "Finance & Accounting",
        "kw": ["FixedAsset", "RAsset", "Asset", "Lease"],
    },
    "project": {
        "source": "asset",
        "entities": ["CDSProjects", "PSAActuals", "PSAForecasts", "ProjGrants", "ProjGrantsV2",
                     "ProjectGroups", "ProjectStages", "ProjectTasks", "Projects", "ProjectsV2"],
        "display": "Project",
        "area": "Project Management",
        "kw": ["Project", "PSA", "ProjGrant"],
    },
    "expense": {
        "source": "asset",
        "entities": ["ExpenseCodes", "ExpenseParameters", "ExpenseRates", "Expenses",
                     "MileageRates", "PerDiems", "TrvReceipts"],
        "display": "Expense",
        "area": "Finance & Accounting",
        "kw": ["Expense", "Travel", "Mileage", "PerDiem"],
    },
    "cashmanagement": {
        "source": "asset",
        "entities": ["BankAccounts", "BankGroups", "CashAccounts", "CashBalances",
                     "CashDiscounts", "CashLedgers", "CashSymbols", "CodaTrans", "ExchSetups"],
        "display": "Cash Management",
        "area": "Finance & Accounting",
        "kw": ["Bank", "Cash", "Exchange", "Finance"],
    },
    # ---- From core ----
    "core": {
        "source": "core",
        "entities": ["AddressBooks", "AddressCities", "AddressFormats", "AddressObjects",
                     "AddressStates", "Branches", "BusinessUnits", "CDSParties", "Companies",
                     "Departments", "DepartmentsV2"],
        "display": "Core",
        "area": "Finance & Accounting",
        "kw": ["Company", "Organization", "Address", "Department"],
    },
    "coreorg": {
        "source": "core",
        "entities": ["CardTypes", "Categories", "DirParameters", "ELCOAs", "EmplPostings",
                     "LanguageCodes", "LegalEntities", "NameAffixes", "NameSequences",
                     "Salutations", "VATNumTables", "Warehouses"],
        "display": "Core Organization",
        "area": "Finance & Accounting",
        "kw": ["LegalEntity", "Warehouse", "Organization", "Reference"],
    },
    "payment": {
        "source": "core",
        "entities": ["Currencies", "CurrencyRules", "Denominations", "ExchangeRates",
                     "ExchangeRatesNonISO", "PaymentCalendarRules", "PaymentDays",
                     "PaymentInstructions", "PaymentMethods", "PaymentTerms", "VRMCurrencies",
                     "VRMLanguages", "VRMParameters", "VRMPeople", "VRMTaxGroups", "VoucherTypes"],
        "display": "Payment",
        "area": "Finance & Accounting",
        "kw": ["Payment", "Currency", "Exchange", "VRM"],
    },
    # ---- From hr ----
    "hr": {
        "source": "hr",
        "entities": ["AbsenceCodes", "AbsenceReasons", "CityHolidays", "Employments", "EssWorkers",
                     "InjuryTypes", "People", "PersonImages", "PersonUsers", "StateHolidays"],
        "display": "Human Resources",
        "area": "Human Resources",
        "kw": ["HR", "Employee", "Worker", "Person"],
    },
    "hrdev": {
        "source": "hr",
        "entities": ["CourseGroups", "JobTasks", "JobTemplates", "LaborUnions", "LoanItems",
                     "LoanTypes", "PositionTypes", "RatingLevels", "RatingModels", "SkillTypes",
                     "Skills", "TeamMembers", "TeamMembersV2", "Teams", "TeamsV2", "Unions",
                     "VestingRules"],
        "display": "HR Development",
        "area": "Human Resources",
        "kw": ["HR", "Skills", "Training", "Team"],
    },
    # ---- From ledger ----
    "ledger": {
        "source": "ledger",
        "entities": ["Accountants", "AccrualSchemes", "AuditTrails", "LedgerIntervals",
                     "LedgerJournalDescriptions", "LedgerJournalHeaders", "OpeningSheets",
                     "PostingDefinitions", "PostingJournals"],
        "display": "Ledger",
        "area": "Finance & Accounting",
        "kw": ["Ledger", "Journal", "Accounting", "Posting"],
    },
    "journalentry": {
        "source": "ledger",
        "entities": ["JournalLines", "JournalNames", "JournalTables", "JournalTrans",
                     "LedgerJournalLines", "LedgerTransSettlements", "LedgerTransSettlementsV2"],
        "display": "Journal Entry",
        "area": "Finance & Accounting",
        "kw": ["Journal", "Ledger", "Entry", "Transaction"],
    },
    "mainaccount": {
        "source": "ledger",
        "entities": ["LeaseBooks", "LedgerAccountGroups", "Ledgers", "MainAccountLegalEntities",
                     "MainAccounts"],
        "display": "Main Account",
        "area": "Finance & Accounting",
        "kw": ["Ledger", "MainAccount", "ChartOfAccounts"],
    },
    "budget": {
        "source": "ledger",
        "entities": ["BudgetCodes", "BudgetCycles", "BudgetModels", "BudgetPlanProcesses",
                     "BudgetPlans", "CPJournals", "CPParameters", "CPPortfolios", "CPTables",
                     "CPTrans", "CostCenters", "CostGroups", "FundTypes", "Funds", "PeriodLines"],
        "display": "Budget",
        "area": "Finance & Accounting",
        "kw": ["Budget", "CostCenter", "Fund", "ControlPlan"],
    },
    "fiscal": {
        "source": "ledger",
        "entities": ["DimensionAttributes", "DimensionParameters", "DimensionRules",
                     "DimensionSets", "FinancialDimensionSets", "FinancialDimensionValues",
                     "FiscalCalendars", "FiscalPeriods", "FiscalYears"],
        "display": "Fiscal",
        "area": "Finance & Accounting",
        "kw": ["Fiscal", "Dimension", "FinancialDimension"],
    },
    # ---- From payable ----
    "vendor": {
        "source": "payable",
        "entities": ["VendorGroups", "VendorParameters", "VendorReasons", "Vendors"],
        "display": "Vendor",
        "area": "Accounts Payable",
        "kw": ["Vendor", "AccountsPayable", "AP"],
    },
    "vendorextended": {
        "source": "payable",
        "entities": ["VendorsV2", "VendorsV3"],
        "display": "Vendor Extended",
        "area": "Accounts Payable",
        "kw": ["Vendor", "AccountsPayable", "AP"],
    },
    "vendorpayment": {
        "source": "payable",
        "entities": ["PayAgreements", "VendPWPTxts", "VendorPaymentJournalHeaders",
                     "VendorPaymentJournalLines", "VendorPaymentMethods"],
        "display": "Vendor Payment",
        "area": "Accounts Payable",
        "kw": ["Vendor", "Payment", "AccountsPayable"],
    },
    "procurement": {
        "source": "payable",
        "entities": ["DeliveryTerms", "DiscountRates", "IntentLetters", "VendorInvoiceDeclarations"],
        "display": "Procurement",
        "area": "Accounts Payable",
        "kw": ["Procurement", "Vendor", "PurchaseOrder", "Delivery"],
    },
    # ---- From receivable ----
    "customer": {
        "source": "receivable",
        "entities": ["CustomerGroups", "CustomerParameters", "Customers", "CustomersBase"],
        "display": "Customer",
        "area": "Accounts Receivable",
        "kw": ["Customer", "AccountsReceivable", "AR"],
    },
    "customermain": {
        "source": "receivable",
        "entities": ["CustomersV2", "CustomersV3"],
        "display": "Customer Main",
        "area": "Accounts Receivable",
        "kw": ["Customer", "AccountsReceivable", "AR"],
    },
    "customeraccount": {
        "source": "receivable",
        "entities": ["CustomerElectronicAddresses", "CustomerPaymentJournalHeaders",
                     "CustomerPaymentJournalLines", "CustomerPaymentMethods",
                     "CustomerPostalAddressesV2", "CustomerPostingProfiles"],
        "display": "Customer Account",
        "area": "Accounts Receivable",
        "kw": ["Customer", "Payment", "AccountsReceivable"],
    },
    "receivable": {
        "source": "receivable",
        "entities": ["AdvLines", "CustDisputes", "CustomApis", "CustomFields", "CustomOffices",
                     "DebtPeriods", "DueDateLimits", "Plafonds", "ReturnDetails", "SalesCarriers",
                     "SalesLists"],
        "display": "Receivable",
        "area": "Accounts Receivable",
        "kw": ["Receivable", "Dispute", "Collections", "Sales"],
    },
    # ---- From system ----
    "workflow": {
        "source": "system",
        "entities": ["ActionClasses", "Actions", "AdvancedRules", "ApprovalUsers", "BatchGroups",
                     "BatchJobs", "DatabaseLogs", "Operations", "PolicyRules", "PolicyTypes",
                     "ProcessStages", "RecSetupBases", "Workflows"],
        "display": "Workflow",
        "area": "System",
        "kw": ["Workflow", "Batch", "Automation", "Policy"],
    },
    "document": {
        "source": "system",
        "entities": ["AgentFeeds", "Agents", "DemoDataPosts", "DocumentTypes", "Documents",
                     "EDParameters", "Guides", "Media", "MediaTypes", "MessageItems",
                     "MessageStatus", "MessagesLogs", "PrintLayouts"],
        "display": "Document",
        "area": "System",
        "kw": ["Document", "Media", "Message", "Agent"],
    },
    "trade": {
        "source": "system",
        "entities": ["BLWI", "Intrastats", "IntrastatsV2", "NAFCodes", "NGPCodes", "Report347",
                     "ReportPeriods", "SADGroups", "SADItemCodes", "SADParameters", "TNVEDCodes"],
        "display": "Trade",
        "area": "Compliance",
        "kw": ["Trade", "Intrastat", "Compliance", "International"],
    },
    "users": {
        "source": "system",
        "entities": ["ChannelUsers", "ExternalRoles", "Groups", "SecurityRoles", "SourceSystems",
                     "SourceTypes", "SysAADClients", "SysMonDatas", "SystemUsers", "UserGroups"],
        "display": "Users",
        "area": "System",
        "kw": ["User", "Security", "Role", "Identity"],
    },
    "system": {
        "source": "system",
        "entities": ["Abbreviations", "AllProducts", "CFPSTable", "Components", "DateIntervals",
                     "EMItemTypes", "EstateStatus", "ExtCodeTables", "FormatCodes", "Houses",
                     "ImportModes", "ItemGTDs", "LoadTemplates", "LoyaltyLevels", "ModelTables",
                     "OfBusinesses", "OtherClients", "Parameters", "ServiceCodes", "SiteGate"],
        "display": "System",
        "area": "System",
        "kw": ["System", "Configuration", "Reference"],
    },
    "sysconfig": {
        "source": "system",
        "entities": ["PSSerialLines", "ProductTypes", "RBSLFactors", "Reasons", "Registrations",
                     "Rooms", "State11", "StdSeqs", "Steads", "TableDatas", "TableMappings",
                     "Tables", "Tests", "TransDatas", "TypeTables", "Types", "WebServices",
                     "WorkCalendars"],
        "display": "System Config",
        "area": "System",
        "kw": ["System", "Configuration", "Reference", "Tables"],
    },
    # ---- From tax ----
    "tax": {
        "source": "tax",
        "entities": ["CFOPCodes", "CFOPGroups", "ELParameters", "GSTMinorCodes", "HSNCodes",
                     "TaxCodeLimits", "TaxCodes", "TaxGroupDatas", "TaxGroups", "TaxItemGroups",
                     "TaxParameters", "TaxPeriods", "TaxPostingGroups", "TaxRegions", "TaxTables",
                     "TaxationCode", "TaxesMatrices"],
        "display": "Tax",
        "area": "Tax",
        "kw": ["Tax", "VAT", "GST", "Taxation"],
    },
    "taxregion": {
        "source": "tax",
        "entities": ["EFDocSchemas", "ISRConcepts", "ISRRates", "Intervats", "NIPTables",
                     "NRTaxTrans", "Tax1099Fields", "TaxDocuments"],
        "display": "Tax Region",
        "area": "Tax",
        "kw": ["Tax", "Regional", "Compliance", "Country"],
    },
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def singular(entity_set: str) -> str:
    """Convert entity set name (plural) to singular for type name matching."""
    for v in ["V2", "V3", "V4"]:
        if entity_set.endswith("s" + v):
            return entity_set[: -len("s" + v)] + v
    if entity_set.endswith("ses"):
        return entity_set[:-2]
    if entity_set.endswith("ies"):
        return entity_set[:-3] + "y"
    if entity_set.endswith("s"):
        return entity_set[:-1]
    return entity_set


def get_prefixes(entity_set: str) -> list[str]:
    """Return all type-name prefixes that belong to this entity set."""
    sing = singular(entity_set)
    prefixes = [entity_set]
    if sing != entity_set:
        prefixes.append(sing)
    return prefixes


def best_match(type_name: str, all_entity_sets: list[str]) -> str | None:
    """Return the entity set whose prefix best matches type_name, or None."""
    best_ent = None
    best_len = 0
    for ent in all_entity_sets:
        for prefix in get_prefixes(ent):
            if type_name.startswith(prefix) and len(prefix) > best_len:
                best_ent = ent
                best_len = len(prefix)
    return best_ent


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

def read_all_lines(source_module: str) -> list[str]:
    """Read all lines from types_seg_*.bal files for a source module, stripping import lines."""
    module_dir = BAL_DIR / source_module
    lines = []
    skip_prefixes = ("import ", "// AUTO-GENERATED", "// This file is auto-generated")
    for seg_file in sorted(module_dir.glob("types_seg_*.bal")):
        for line in seg_file.read_text().splitlines(keepends=True):
            stripped = line.strip()
            if any(stripped.startswith(p) for p in skip_prefixes) or stripped == "":
                continue
            lines.append(line)
    return lines


def parse_type_blocks(lines: list[str]) -> list[tuple[str, str]]:
    """
    Parse Ballerina type definitions from lines.
    Returns list of (type_name, full_block_text_including_doc_comment).
    """
    blocks = []
    n = len(lines)
    i = 0
    while i < n:
        line = lines[i]
        stripped = line.strip()
        # Find a "public type" declaration
        m = re.match(r"^public type (\S+)", stripped)
        if not m:
            i += 1
            continue
        type_name = m.group(1)
        # Walk back to collect preceding doc-comment lines
        doc_start = i
        while doc_start > 0 and lines[doc_start - 1].strip().startswith("#"):
            doc_start -= 1
        # Collect the type block until it ends
        block_lines = list(lines[doc_start:i])  # doc comment lines
        # Now consume the type definition itself
        depth = 0
        j = i
        while j < n:
            l = lines[j]
            block_lines.append(l)
            depth += l.count("{") - l.count("}")
            # Simple types end with ";" on the declaration line or when braces close
            if j == i and ";" in l and "{" not in l:
                # single-line type alias / enum
                j += 1
                break
            if j == i and "{" not in l and depth == 0:
                # single-line without braces (e.g. type alias)
                j += 1
                break
            if depth <= 0 and j > i:
                j += 1
                break
            j += 1
        blocks.append((type_name, "".join(block_lines)))
        i = j
    return blocks


def parse_client_functions(client_bal: Path) -> tuple[str, list[tuple[str, str, str]]]:
    """
    Parse a client.bal file.
    Returns (header_text, [(func_name, entity_set_guess, full_func_text), ...]).
    header_text is everything from start through `public isolated function init(...)`.
    """
    text = client_bal.read_text()
    lines = text.splitlines(keepends=True)
    n = len(lines)

    # Find the end of the init() function block
    in_class = False
    init_end = 0
    depth = 0
    found_init = False
    class_open = 0
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if "public isolated client class Client {" in line:
            in_class = True
            depth = 1
            class_open = idx
            continue
        if not in_class:
            continue
        depth += line.count("{") - line.count("}")
        if "public isolated function init(" in line and not found_init:
            found_init = True
        if found_init and depth == 1:
            # We just closed the init function
            init_end = idx + 1
            break

    header = "".join(lines[:init_end]) + "\n"

    # Parse remote functions
    funcs = []
    i = init_end
    while i < n:
        line = lines[i]
        stripped = line.strip()
        # Find remote function
        m = re.match(r"\s*remote isolated function (\w+)\(", stripped)
        if not m:
            i += 1
            continue
        func_name = m.group(1)
        # Walk back for doc comment
        doc_start = i
        while doc_start > 0 and lines[doc_start - 1].strip().startswith("#"):
            doc_start -= 1
        # Collect function block
        block_lines = list(lines[doc_start:i])
        depth_f = 0
        j = i
        while j < n:
            l = lines[j]
            block_lines.append(l)
            depth_f += l.count("{") - l.count("}")
            if depth_f <= 0 and j > i:
                j += 1
                break
            j += 1
        funcs.append((func_name, "".join(block_lines)))
        i = j
    return header, funcs


# ---------------------------------------------------------------------------
# Assignment: map types and functions to packages for a given source module
# ---------------------------------------------------------------------------

def assign_to_packages(source_module: str) -> tuple[
    dict[str, list[tuple[str, str]]],   # pkg -> [(name, text)]
    dict[str, list[tuple[str, str]]],   # pkg -> [(fname, text)]
    str,                                # client header
]:
    """Return per-package types, per-package functions, and client header."""
    pkgs_for_mod = {name: cfg for name, cfg in PACKAGES.items()
                    if cfg["source"] == source_module}
    all_entities = [e for cfg in pkgs_for_mod.values() for e in cfg["entities"]]

    # entity -> package mapping
    entity_to_pkg: dict[str, str] = {}
    for pkg_name, cfg in pkgs_for_mod.items():
        for ent in cfg["entities"]:
            entity_to_pkg[ent] = pkg_name

    # Parse types
    lines = read_all_lines(source_module)
    type_blocks = parse_type_blocks(lines)

    # Assign types
    pkg_types: dict[str, list] = {p: [] for p in pkgs_for_mod}
    orphaned_types: list[tuple[str, str]] = []
    for type_name, block in type_blocks:
        matched_ent = best_match(type_name, all_entities)
        if matched_ent:
            pkg = entity_to_pkg[matched_ent]
            pkg_types[pkg].append((type_name, block))
        else:
            orphaned_types.append((type_name, block))

    # Resolve cross-package type references within this module.
    # Any assigned type referenced by a type in another package (or by orphaned types
    # that go to ALL packages) gets promoted to shared. Repeat until stable.
    if len(pkgs_for_mod) > 1:
        import re as _re
        # Build name->block lookup for assigned types only
        type_owner: dict[str, str] = {}
        type_block_map: dict[str, str] = {}
        for pkg_name, type_list in pkg_types.items():
            for tname, tblock in type_list:
                type_owner[tname] = pkg_name
                type_block_map[tname] = tblock

        # Iteratively promote until stable: each round checks orphaned text (which
        # grows as types are promoted) + per-package assigned-type text.
        changed = True
        while changed:
            changed = False
            # Orphaned types go to ALL packages — any assigned type they reference
            # must also be shared.
            orphaned_text = "".join(b for _, b in orphaned_types)
            for used_type in set(_re.findall(r'\b([A-Z][a-zA-Z0-9]+)\b', orphaned_text)):
                if used_type in type_owner:
                    orphaned_types.append((used_type, type_block_map[used_type]))
                    pkg_types[type_owner[used_type]] = [
                        (n, b) for n, b in pkg_types[type_owner[used_type]] if n != used_type
                    ]
                    del type_owner[used_type]
                    changed = True
            # Also promote assigned types referenced by other packages' assigned types.
            for pkg_name, type_list in list(pkg_types.items()):
                for used_type in set(_re.findall(r'\b([A-Z][a-zA-Z0-9]+)\b',
                                                  "".join(b for _, b in type_list))):
                    owner = type_owner.get(used_type)
                    if owner and owner != pkg_name:
                        orphaned_types.append((used_type, type_block_map[used_type]))
                        pkg_types[owner] = [
                            (n, b) for n, b in pkg_types[owner] if n != used_type
                        ]
                        del type_owner[used_type]
                        changed = True

    # Second pass: try verb-stripped matching for remaining orphaned types.
    # e.g. ListCPJournalsQueries -> CPJournals -> best_match -> budget package
    if len(pkgs_for_mod) > 1:
        VERB_PREFIXES = ["ListV2", "CreateV2", "GetV2", "DeleteV2", "UpdateV2",
                         "List", "Create", "Get", "Delete", "Update"]
        TYPE_SUFFIXES = ["Queries", "Headers"]
        still_orphaned: list[tuple[str, str]] = []
        for type_name, block in orphaned_types:
            candidate = type_name
            for verb in VERB_PREFIXES:
                if candidate.startswith(verb):
                    candidate = candidate[len(verb):]
                    break
            for suffix in TYPE_SUFFIXES:
                if candidate.endswith(suffix):
                    candidate = candidate[:-len(suffix)]
                    break
            if candidate != type_name:
                matched_ent = best_match(candidate, all_entities)
                if matched_ent:
                    pkg_types[entity_to_pkg[matched_ent]].append((type_name, block))
                    continue
            still_orphaned.append((type_name, block))
        orphaned_types = still_orphaned

    # Parse client functions now (before orphaned assignment) so client_header
    # type refs are included in the transitive closure seed.
    client_bal = BAL_DIR / source_module / "client.bal"
    client_header, all_funcs = parse_client_functions(client_bal)

    # Add only the orphaned types actually needed by each package (transitive closure).
    # Seed includes both entity types and the client header (e.g. ConnectionConfig).
    orphaned_map = {name: block for name, block in orphaned_types}
    if len(pkgs_for_mod) > 1 and orphaned_map:
        import re as _re2
        for pkg_name in pkgs_for_mod:
            pkg_body = "".join(block for _, block in pkg_types[pkg_name]) + client_header
            direct_refs = set(_re2.findall(r'\b([A-Z][a-zA-Z0-9]+)\b', pkg_body))
            needed: set[str] = set()
            queue = [n for n in direct_refs if n in orphaned_map]
            while queue:
                t = queue.pop()
                if t in needed:
                    continue
                needed.add(t)
                refs = set(_re2.findall(r'\b([A-Z][a-zA-Z0-9]+)\b', orphaned_map[t]))
                queue.extend(n for n in refs if n in orphaned_map and n not in needed)
            needed_orphaned = [(n, orphaned_map[n]) for n in needed]
            pkg_types[pkg_name] = needed_orphaned + pkg_types[pkg_name]
    else:
        for pkg_name in pkgs_for_mod:
            pkg_types[pkg_name] = orphaned_types + pkg_types[pkg_name]

    # Assign functions: derive entity set from function name
    pkg_funcs: dict[str, list] = {p: [] for p in pkgs_for_mod}
    for func_name, func_text in all_funcs:
        # Function names like listMainAccounts, createMainAccounts, etc.
        # Strip verb prefix: list, create, get, delete, update
        for verb in ["listV2", "createV2", "getV2", "deleteV2", "updateV2",
                     "list", "create", "get", "delete", "update"]:
            if func_name.startswith(verb):
                entity_candidate = func_name[len(verb):]
                # Find which entity set this matches
                matched_ent = None
                best_len = 0
                for ent in all_entities:
                    if entity_candidate == ent or entity_candidate.startswith(ent):
                        if len(ent) > best_len:
                            matched_ent = ent
                            best_len = len(ent)
                if matched_ent:
                    pkg = entity_to_pkg[matched_ent]
                    pkg_funcs[pkg].append((func_name, func_text))
                    break
                # Also try exact match of entity_candidate against entity set names
                if entity_candidate in entity_to_pkg:
                    pkg_funcs[entity_to_pkg[entity_candidate]].append((func_name, func_text))
                    break
        else:
            # No verb matched - assign to first package (shouldn't happen)
            first_pkg = next(iter(pkgs_for_mod))
            pkg_funcs[first_pkg].append((func_name, func_text))

    return pkg_types, pkg_funcs, client_header


# ---------------------------------------------------------------------------
# File generation
# ---------------------------------------------------------------------------

COPYRIGHT = """\
// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
"""


TYPES_COMMENT_HEADER = (
    "// AUTO-GENERATED FILE. DO NOT MODIFY.\n"
    "// This file is auto-generated by the Ballerina OpenAPI tool.\n\n"
)


def build_types_header(content: str) -> str:
    """Build the import header for a types file based on what it uses."""
    imports = []
    if "jsondata:" in content:
        imports.append("import ballerina/data.jsondata;")
    if "http:" in content:
        imports.append("import ballerina/http;")
    if imports:
        return TYPES_COMMENT_HEADER + "\n".join(imports) + "\n\n"
    return TYPES_COMMENT_HEADER


def write_types_bal(pkg_dir: Path, types: list[tuple[str, str]]) -> None:
    """Write a single types.bal. Warns if over 1700 lines (split into more packages instead)."""
    body = "".join(block for _, block in types)
    line_count = body.count("\n")
    if line_count > 1700:
        print(f"  WARNING: {pkg_dir.name}/types.bal is {line_count} lines — split into more packages")
    (pkg_dir / "types.bal").write_text(build_types_header(body) + body)


def write_client_bal(pkg_dir: Path, header: str, funcs: list[tuple[str, str]]) -> None:
    body = header
    for _, func_text in funcs:
        body += func_text + "\n"
    body += "}\n"
    (pkg_dir / "client.bal").write_text(body)


def write_ballerina_toml(pkg_dir: Path, pkg_name: str, cfg: dict, version: str) -> None:
    full_name = f"microsoft.dynamics365.finance.{pkg_name}"
    kw_list = (
        [f"Name/Microsoft Dynamics 365 Finance {cfg['display']}",
         f"Area/{cfg['area']}", "Vendor/Microsoft", "Dynamics365", "Finance", "ERP",
         "Type/Connector"]
        + cfg["kw"]
    )
    keywords = ", ".join(f'"{k}"' for k in kw_list)
    content = f"""[package]
org = "ballerinax"
name = "{full_name}"
version = "{version}"
authors = ["Ballerina"]
keywords = [{keywords}]
repository = "https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance"
icon = "../icon.png"
license = ["Apache-2.0"]
distribution = "2201.13.0"

[[package.modules]]
name = "{full_name}.mock"

[build-options]
observabilityIncluded = true
"""
    (pkg_dir / "Ballerina.toml").write_text(content)


def write_build_config_toml(pkg_name: str, cfg: dict) -> None:
    full_name = f"microsoft.dynamics365.finance.{pkg_name}"
    kw_list = (
        [f"Name/Microsoft Dynamics 365 Finance {cfg['display']}",
         f"Area/{cfg['area']}", "Vendor/Microsoft", "Dynamics365", "Finance", "ERP",
         "Type/Connector"]
        + cfg["kw"]
    )
    keywords = ", ".join(f'"{k}"' for k in kw_list)
    tpl_dir = BUILD_CFG_DIR / pkg_name
    tpl_dir.mkdir(parents=True, exist_ok=True)
    content = f"""[package]
org = "ballerinax"
name = "{full_name}"
version = "@toml.version@"
authors = ["Ballerina"]
keywords = [{keywords}]
repository = "https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance"
icon = "../icon.png"
license = ["Apache-2.0"]
distribution = "2201.13.0"

[[package.modules]]
name = "{full_name}.mock"

[build-options]
observabilityIncluded = true
"""
    (tpl_dir / "Ballerina.toml").write_text(content)


def write_build_gradle(pkg_dir: Path, pkg_name: str, cfg: dict) -> None:
    full_name = f"microsoft.dynamics365.finance.{pkg_name}"
    var_name = f"{pkg_name}Version"
    content = f"""\
/*
 * Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com)
 * Apache License 2.0
 */
import org.apache.tools.ant.taskdefs.condition.Os

plugins {{
    id 'net.researchgate.release'
    id 'io.ballerina.plugin'
}}

description = 'Ballerinax - Microsoft Dynamics 365 Finance and Operations - {cfg["display"]} Module'

def packageName = "{full_name}"
def tomlVersion = stripBallerinaExtensionVersion("${{project.{var_name}}}")
def ballerinaTomlFilePlaceHolder = new File("${{project.rootDir}}/build-config/resources/{pkg_name}/Ballerina.toml")
def ballerinaTomlFile = new File("$project.projectDir/Ballerina.toml")

def stripBallerinaExtensionVersion(String extVersion) {{
    if (extVersion.matches(project.ext.timestampedVersionRegex)) {{
        def splitVersion = extVersion.split('-')
        if (splitVersion.length > 3) {{
            return splitVersion[0..-4].join('-')
        }}
        return extVersion
    }}
    return extVersion.replace("${{project.ext.snapshotVersion}}", "")
}}

ballerina {{
    packageOrganization = "ballerinax"
    module = packageName
    isConnector = true
    platform = "any"
    testCoverageParam = '--code-coverage --coverage-format=xml'
}}

task updateTomlFiles {{
    doLast {{
        def newConfig = ballerinaTomlFilePlaceHolder.text.replace("@project.version@", project.version)
        newConfig = newConfig.replace("@toml.version@", tomlVersion)
        ballerinaTomlFile.text = newConfig
    }}
}}

task commitTomlFiles {{
    doLast {{
        project.exec {{
            ignoreExitValue true
            if (Os.isFamily(Os.FAMILY_WINDOWS)) {{
                commandLine 'cmd', '/c', "git commit -m '[Automated] Update the toml files' Ballerina.toml Dependencies.toml"
            }} else {{
                commandLine 'sh', '-c', "git commit -m '[Automated] Update the toml files' Ballerina.toml Dependencies.toml"
            }}
        }}
    }}
}}

release {{
    buildTasks = ['build']
    failOnSnapshotDependencies = true
    versionPropertyFile = '../../gradle.properties'
    versionProperties = ['{var_name}']
    tagTemplate = '{pkg_name}-v${{version}}'
    git {{
        requireBranch = "release-{pkg_name}-${{tomlVersion}}"
        pushToRemote = 'origin'
    }}
}}

build.dependsOn updateTomlFiles
publishToMavenLocal.dependsOn build
publish.dependsOn build

tasks.whenTaskAdded {{ task ->
    if (task.name == 'test') {{
        task.doFirst {{
            new File("${{project.projectDir}}/target/cache/tests_cache/coverage").mkdirs()
        }}
    }}
}}
"""
    (pkg_dir / "build.gradle").write_text(content)


def write_mock_files(pkg_dir: Path, pkg_name: str) -> None:
    mock_dir = pkg_dir / "modules" / "mock"
    mock_dir.mkdir(parents=True, exist_ok=True)

    # Copy odata.bal from ledger (generic)
    src_odata = BAL_DIR / "ledger" / "modules" / "mock" / "odata.bal"
    shutil.copy(src_odata, mock_dir / "odata.bal")

    # Copy service.bal from ledger (generic)
    src_service = BAL_DIR / "ledger" / "modules" / "mock" / "service.bal"
    shutil.copy(src_service, mock_dir / "service.bal")

    # Write minimal data.bal
    data_content = f"""\
{COPYRIGHT}
// Minimal stub data for the {pkg_name} mock — returns empty collections.

isolated function dataFor(string entitySet) returns json[] {{
    return [];
}}
"""
    (mock_dir / "data.bal").write_text(data_content)


def write_test_bal(pkg_dir: Path, pkg_name: str, funcs: list[tuple[str, str]]) -> None:
    test_dir = pkg_dir / "tests"
    test_dir.mkdir(parents=True, exist_ok=True)

    full_name = f"microsoft.dynamics365.finance.{pkg_name}"
    # Pick first list function for a smoke test
    first_list = next((f for f, _ in funcs if f.startswith("list")), None)

    test_func = ""
    if first_list:
        # Derive return type from function name: listXxx -> XxxsCollection or XxxCollection
        entity_name = first_list[4:]  # strip "list"
        return_type = f"{entity_name}Collection"
        test_func = f"""\
@test:Config
function testList{entity_name}() returns error? {{
    Client cl = check buildClient();
    {return_type} response = check cl->{first_list}();
    test:assertTrue(response.value !is (), "should return a valid collection");
}}
"""

    content = f"""\
{COPYRIGHT}
import ballerina/http;
import ballerina/test;
import ballerinax/microsoft.dynamics365.finance.{pkg_name}.mock as mockSrv;

configurable boolean isTestOnLiveServer = false;

configurable string serviceUrl = "http://localhost:9090/data";
configurable string clientId = "mock-client-id";
configurable string clientSecret = "mock-client-secret";
configurable string tenantId = "mock-tenant-id";

http:Listener mockListener = check new (9090);

@test:BeforeSuite
function startMock() returns error? {{
    if !isTestOnLiveServer {{
        mockListener = check mockSrv:startMock();
    }}
}}

@test:AfterSuite
function stopMock() returns error? {{
    if !isTestOnLiveServer {{
        check mockListener.gracefulStop();
    }}
}}

function buildClient() returns Client|error {{
    if isTestOnLiveServer {{
        return new (
            {{
                auth: {{
                    tokenUrl: string `https://login.microsoftonline.com/${{tenantId}}/oauth2/v2.0/token`,
                    clientId,
                    clientSecret
                }}
            }},
            serviceUrl
        );
    }}
    return new (
        {{
            auth: {{
                tokenUrl: "http://localhost:9090/token",
                clientId,
                clientSecret
            }}
        }},
        serviceUrl
    );
}}

{test_func}
"""
    (test_dir / "test.bal").write_text(content)


def write_utils_bal(pkg_dir: Path, utils_text: str) -> None:
    (pkg_dir / "utils.bal").write_text(utils_text)


def write_readme(pkg_dir: Path, pkg_name: str, cfg: dict) -> None:
    """Generate README.md from the shared template so the file is tracked by git."""
    template_path = BUILD_CFG_DIR.parent.parent / "build-config" / "resources" / "README.md"
    if not template_path.exists():
        return
    full_pkg = f"microsoft.dynamics365.finance.{pkg_name}"
    entities_example = cfg["entities"][:3] if cfg["entities"] else ["Entity"]
    first_entity = entities_example[0] if entities_example else "Entity"
    list_func = f"list{first_entity}"
    collection_type = f"{first_entity}Collection"
    key_features = "\n".join([
        f"- Manage {cfg['display'].lower()} entities in Microsoft Dynamics 365 Finance",
        "- Support for list, create, read, update, and delete operations",
        "- OAuth2 client credentials authentication",
    ])
    content = template_path.read_text()
    content = content.replace("@package-name@", full_pkg)
    content = content.replace("@description@", f"The `{full_pkg}` connector provides access to Microsoft Dynamics 365 Finance {cfg['display']} entities via the OData REST API.")
    content = content.replace("@key-features@", key_features)
    content = content.replace("@communication-scenario@", f"Connecting to Microsoft Dynamics 365 Finance {cfg['display']} API")
    content = content.replace("@import-statement@", f"import ballerinax/{full_pkg};")
    content = content.replace("@client-init@", f"{pkg_name}:Client cl = check new ({{")
    content = content.replace("@api-invocation@", f"{pkg_name}:{collection_type} results = check cl->{list_func}();")
    (pkg_dir / "README.md").write_text(content)


def write_docs_json(pkg_dir: Path, pkg_name: str, cfg: dict) -> None:
    full_pkg = f"microsoft.dynamics365.finance.{pkg_name}"
    entities_example = cfg["entities"][:3] if cfg["entities"] else ["Entity"]
    first_entity = entities_example[0] if entities_example else "Entity"
    # Derive list function name
    list_func = f"list{first_entity}"
    # Derive collection type
    collection_type = f"{first_entity}Collection"
    # Derive singular
    sing = singular(first_entity) if first_entity.endswith("s") else first_entity

    content = f"""{{
  "description": "The {full_pkg} connector provides access to Microsoft Dynamics 365 Finance {cfg['display']} entities via the OData REST API.",
  "key-features": [
    "Manage {cfg['display'].lower()} entities in Microsoft Dynamics 365 Finance",
    "Support for list, create, read, update, and delete operations",
    "OAuth2 client credentials authentication"
  ],
  "communication-scenario": "Connecting to Microsoft Dynamics 365 Finance {cfg['display']} API",
  "import-statement": "import ballerinax/{full_pkg};",
  "client-init": "{pkg_name}:Client cl = check new ({{auth: {{tokenUrl, clientId, clientSecret}}}}, serviceUrl);",
  "api-invocation": "{pkg_name}:{collection_type} results = check cl->{list_func}();"
}}
"""
    (pkg_dir / "docs.json").write_text(content)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def cleanup_old_source_dir(src_dir: Path, pkg_name: str) -> None:
    """Remove stale files from a source directory that became a new package."""
    # Remove old types_seg_*.bal and types2.bal, types3.bal etc.
    for f in src_dir.glob("types_seg_*.bal"):
        f.unlink(missing_ok=True)
    for f in src_dir.glob("types*.bal"):
        f.unlink(missing_ok=True)
    # Remove old Dependencies.toml (will be regenerated on build)
    (src_dir / "Dependencies.toml").unlink(missing_ok=True)


def generate_all():
    # Collect all source modules
    source_modules = sorted(set(cfg["source"] for cfg in PACKAGES.values()))

    # Phase 1: Pre-load ALL source data into memory before touching any directories
    print("Phase 1: Pre-loading source data...")
    source_data: dict[str, tuple] = {}  # src_mod -> (pkg_types, pkg_funcs, client_header, utils_text)
    for src_mod in source_modules:
        print(f"  Reading {src_mod}...")
        pkg_types, pkg_funcs, client_header = assign_to_packages(src_mod)
        utils_text = (BAL_DIR / src_mod / "utils.bal").read_text()
        source_data[src_mod] = (pkg_types, pkg_funcs, client_header, utils_text)

    # Also pre-load mock files from ledger (used as generic template)
    odata_text = (BAL_DIR / "ledger" / "modules" / "mock" / "odata.bal").read_text()
    service_text = (BAL_DIR / "ledger" / "modules" / "mock" / "service.bal").read_text()

    # Phase 2: Remove old source directories that will be replaced
    # Pre-save Dependencies.toml for packages whose dir == source module dir
    # (e.g. hr, ledger, system) since Phase 2 would delete them before Phase 3 can preserve them.
    old_modules = {"asset", "core", "hr", "ledger", "payable", "receivable", "system", "tax"}
    _pre_saved_deps: dict = {}
    for src_mod in old_modules:
        src_dir = BAL_DIR / src_mod
        deps = src_dir / "Dependencies.toml"
        if deps.exists():
            _pre_saved_deps[src_mod] = deps.read_bytes()

    print("\nPhase 2: Removing old source module directories...")
    for src_mod in sorted(old_modules):
        src_dir = BAL_DIR / src_mod
        if src_dir.exists():
            shutil.rmtree(src_dir)
            print(f"  Removed: ballerina/{src_mod}/")

    # Also remove old build-config/resources entries
    for src_mod in sorted(old_modules):
        old_cfg_dir = BUILD_CFG_DIR / src_mod
        if old_cfg_dir.exists():
            shutil.rmtree(old_cfg_dir)
            print(f"  Removed: build-config/resources/{src_mod}/")

    # Phase 3: Generate all new packages
    print("\nPhase 3: Generating new packages...")
    for src_mod in source_modules:
        pkg_types, pkg_funcs, client_header, utils_text = source_data[src_mod]

        for pkg_name, cfg in PACKAGES.items():
            if cfg["source"] != src_mod:
                continue

            print(f"  [{src_mod}] -> {pkg_name}")
            pkg_dir = BAL_DIR / pkg_name
            if pkg_dir.exists():
                # Preserve Dependencies.toml — it's auto-generated by Ballerina
                # and committed for reproducibility; only regenerate it if absent.
                deps_toml = pkg_dir / "Dependencies.toml"
                saved_deps = deps_toml.read_bytes() if deps_toml.exists() else None
                shutil.rmtree(pkg_dir)
            else:
                # Phase 2 may have deleted this dir already (when pkg_name == src_mod).
                saved_deps = _pre_saved_deps.get(pkg_name)
            pkg_dir.mkdir(parents=True, exist_ok=True)
            if saved_deps is not None:
                (pkg_dir / "Dependencies.toml").write_bytes(saved_deps)

            types = pkg_types[pkg_name]
            funcs = pkg_funcs[pkg_name]

            write_types_bal(pkg_dir, types)
            write_client_bal(pkg_dir, client_header, funcs)
            write_utils_bal(pkg_dir, utils_text)
            # Write mock files inline (no shutil.copy since source dir may be gone)
            mock_dir = pkg_dir / "modules" / "mock"
            mock_dir.mkdir(parents=True, exist_ok=True)
            (mock_dir / "odata.bal").write_text(odata_text)
            (mock_dir / "service.bal").write_text(service_text)
            data_content = (f"{COPYRIGHT}\n// Minimal stub data for the {pkg_name} mock.\n\n"
                           "isolated function dataFor(string entitySet) returns json[] {\n"
                           "    return [];\n}\n")
            (mock_dir / "data.bal").write_text(data_content)
            write_test_bal(pkg_dir, pkg_name, funcs)
            write_ballerina_toml(pkg_dir, pkg_name, cfg, "0.1.0-SNAPSHOT")
            write_build_gradle(pkg_dir, pkg_name, cfg)
            write_build_config_toml(pkg_name, cfg)
            write_docs_json(pkg_dir, pkg_name, cfg)
            write_readme(pkg_dir, pkg_name, cfg)

            # Report size
            types_file = pkg_dir / "types.bal"
            if types_file.exists():
                n_lines = len(types_file.read_text().splitlines())
                extra = ""
                for seg_f in sorted(pkg_dir.glob("types_seg_*.bal")):
                    n2 = len(seg_f.read_text().splitlines())
                    extra += f" + {seg_f.name}:{n2}"
                status = "OK" if n_lines <= 1700 else "WARN"
                print(f"    types:{n_lines}{extra} [{status}], funcs:{len(funcs)}")

    print("\nUpdating build files...")
    update_settings_gradle()
    update_root_build_gradle()
    update_gradle_properties()
    update_ci_examples()
    print("Done!")


def update_settings_gradle():
    pkgs = sorted(PACKAGES.keys())
    buckets_str = ", ".join(f"'{p}'" for p in pkgs)
    content = (BUILD_CFG_DIR.parent.parent / "settings.gradle").read_text()
    # Replace ballerinaBuckets list
    new_content = re.sub(
        r"def ballerinaBuckets = \[.*?\]",
        f"def ballerinaBuckets = [{buckets_str}]",
        content,
        flags=re.DOTALL,
    )
    (BASE_DIR / "settings.gradle").write_text(new_content)


def update_root_build_gradle():
    pkgs = sorted(PACKAGES.keys())
    buckets_str = ", ".join(f"'{p}'" for p in pkgs)
    content = (BAL_DIR / "build.gradle").read_text()
    new_content = re.sub(
        r"def ballerinaBuckets = \[.*?\]",
        f"def ballerinaBuckets = [{buckets_str}]",
        content,
        flags=re.DOTALL,
    )
    (BAL_DIR / "build.gradle").write_text(new_content)


def update_gradle_properties():
    props_file = BASE_DIR / "gradle.properties"
    content = props_file.read_text()
    # Remove old per-module version lines
    content = re.sub(r"\n# Per-module versions\n.*", "", content, flags=re.DOTALL)
    # Add new per-package versions
    new_versions = "\n# Per-package versions\n"
    for pkg in sorted(PACKAGES.keys()):
        new_versions += f"{pkg}Version=0.1.0-SNAPSHOT\n"
    content = content.rstrip() + "\n" + new_versions
    props_file.write_text(content)


def update_ci_examples():
    pkgs = sorted(PACKAGES.keys())
    new_loop = (
        f"for bucket in {' '.join(pkgs)}; do\n"
        "            (cd ballerina/${bucket} && bal pack)\n"
        "            bal push --repository local ballerina/${bucket}/target/bala/ballerinax-microsoft.dynamics365.finance.${bucket}-any-*.bala\n"
        "          done"
    )
    for wf_name in ("ci.yml", "pull-request.yml"):
        wf_file = BASE_DIR / ".github" / "workflows" / wf_name
        content = wf_file.read_text()
        new_content = re.sub(r"for bucket in .*?done", new_loop, content, flags=re.DOTALL)
        wf_file.write_text(new_content)


if __name__ == "__main__":
    generate_all()
