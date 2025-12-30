# RDF Schema & Semantics Compliance Report

## Overview
This document analyzes the compliance of the `rdf_dart` package with the **RDF 1.2 Schema** and **RDF 1.2 Semantics** specifications. The analysis focuses on the inferencing capabilities implemented in `RdfsReasoner` and `EntailmentSolver`.

## 1. RDF Schema (RDFS) Support
**Status:** ✅ **Compliant**

The `RdfsReasoner` class (`lib/src/reasoner/rdfs_reasoner.dart`) implements a forward-chaining rule engine that supports the RDFS entailment regime.

### Vocabulary
The implementation correctly defines and utilizes the core RDFS vocabulary:
- **Classes:** `rdfs:Resource`, `rdfs:Class`, `rdfs:Literal`, `rdfs:Datatype`, `rdfs:ContainerMembershipProperty`, `rdf:Property`, `rdf:List`, `rdf:Statement`.
- **Properties:** `rdfs:domain`, `rdfs:range`, `rdfs:subClassOf`, `rdfs:subPropertyOf`, `rdfs:label`, `rdfs:comment`, `rdfs:seeAlso`, `rdfs:isDefinedBy`, `rdfs:member`.
- **Utility:** `rdf:value`, `rdf:type`, `rdf:first`, `rdf:rest`, `rdf:nil`, `rdf:subject`, `rdf:predicate`, `rdf:object`.

### Entailment Rules
The reasoner implements the standard RDFS entailment patterns (rules rdfs1–rdfs13):
- **Domain & Range (`rdfs2`, `rdfs3`):** Infers `rdf:type` based on property usage.
- **Subclassing (`rdfs8`, `rdfs9`, `rdfs10`, `rdfs11`):** Handles `subClassOf` transitivity, reflexivity, and inheritance.
- **Subproperties (`rdfs5`, `rdfs6`, `rdfs7`):** Handles `subPropertyOf` transitivity, reflexivity, and inheritance.
- **Datatypes (`rdfs1`, `rdfs13`):** Infers `rdfs:Datatype` and `subClassOf rdfs:Literal`.
- **Container Membership (`rdfs12`, specialized logic):** Supports `rdfs:ContainerMembershipProperty` and `rdf:_n` expansion.

## 2. RDF Semantics Support
**Status:** ✅ **Compliant**

The `EntailmentSolver` (`lib/src/reasoner/entailment_solver.dart`) implements satisfiability and entailment checking.

### Entailment Regimes
- **Simple Entailment:** Supported. The solver performs subgraph isomorphism checks with blank node mapping (interpolation lemma).
- **D-Entailment (Datatypes):** Supported.
    - **Value Mapping:** Uses `_termsAreDEquivalent` to equate literals with different lexical forms but identical values (e.g., `"1"^^xsd:int` vs `"01"^^xsd:int`).
    - **Signed Zero:** Correctly distinguishes `-0.0` and `0.0` for floating-point types (`xsd:double`, `xsd:float`).
    - **Recursive Matching:** Correctly handles Triple Terms containing D-equivalent literals (e.g., `<<( s p "1"^^int )>>` equals `<<( s p "01"^^int )>>`).
- **RDFS Entailment:** Supported via the `RdfsReasoner` which materializes the deductive closure before entailment checking.

### RDF 1.2 Specifics
- **Triple Terms:**
    - The reasoner includes axioms for `rdf:reifies` range (`rdfs:Proposition`).
    - `TripleTerm` is correctly treated as a `SubjectTerm` only when wrapped (in `TripleTerm` class), though essentially denoting a resource. The solver handles blank node scoping within triple terms correctly.
- **Propositions:** The reasoner infers `rdfs:Proposition` type for reified triples.

## 3. Implementation Details
- **Forward Chaining:** `RdfsReasoner` uses a saturation loop (`while (changed) ...`) to compute the finite closure of the graph.
- **Backtracking Search:** `EntailmentSolver` uses a recursive backtracking algorithm to find valid blank node mappings for simple entailment.
- **Axiomatic Triples:** The reasoner explicitly adds the infinite set of axiomatic triples required by RDF/RDFS (e.g., `rdf:type rdf:type rdf:Property`) at initialization.

## Recommendations
- **Finite Closure:** The current saturation loop might not terminate if rules generate infinite new blank nodes (though standard RDFS rules don't). Ensure safety against custom rules if added later.
- **Performance:** For large graphs, the naive saturation loop and backtracking solver may be slow. Consider optimizing with Rete-like algorithms or indexing.
