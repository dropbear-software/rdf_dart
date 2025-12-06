# RDF Abstract Data Model Requirements

## RDF Graph 
- Section 3 of the RDF 1.2 Concepts spec https://www.w3.org/TR/rdf12-concepts/#section-rdf-graph 
- An `RDF graph` is a `set` of `RDF triples`.
- An `RDF triple` that is an element of an `RDF graph` is also said to be `asserted` in that `RDF graph`

### Triples
- Section 3.1 of the RDF 1.2 Concepts spec https://www.w3.org/TR/rdf12-concepts/#section-triples
- An RDF triple (often simply called "triple") is a 3-tuple that is defined inductively as follows:
    - If s is an `IRI` or a `blank node`, p is an `IRI`, and o is an `IRI`, a `blank node`, or a `literal`, then (s, p, o) is an `RDF triple`.
    - If s is an `IRI` or a `blank node`, p is an `IRI`, and o is an `RDF triple`, then (s, p, o) is an `RDF triple`.
- The three components (s, p, o) of an `RDF triple` are respectively called the `subject`, `predicate` and `object` of the triple.
- The set of `nodes` of an `RDF graph` is the set of `subjects` and `objects` of the `asserted triples` of the `graph`. It is possible for a `predicate IRI` to also occur as a `node` in the same `graph`.

### RDF Terms
- Section 3.1 of the RDF 1.2 Concepts spec https://www.w3.org/TR/rdf12-concepts/#section-terms
- `IRIs`, `literals`, `blank nodes`, and `triple terms` are collectively known as `RDF terms`.
- `IRIs`, `literals` and `blank nodes` are said to be `basic RDF terms`.
- **RDF term equality**: Two `RDF terms` `t` and `t'` are equal (the same RDF term) **if and only if** one of the following four conditions holds:
    - `t` and `t'` are both `IRIs` and their `IRIs` are equal. (per IRI Equality)
    - `t` and `t'` are both `literals` and their `literals` are equal. (per Literal Term Equality)
    - `t` and `t'` are both `blank nodes` and their `blank nodes` are equal. (per Blank Node Equality)
    - `t` and `t'` are both `triple terms` and their `triple terms` are equal. (per Triple Equality)
- **Note**: From the above definition of RDF term equality, it follows that terms of different kinds (IRI, literal, blank node, or triple term) are always distinguishable, even if they are otherwise based on the same string. For example, the `IRI` http://example.org/ is not equal to a `literal` whose `lexical form` is http://example.org/.
- The `set` of `RDF terms` `appearing` in an `RDF triple` `t` is defined inductively as follows:
    - The `subject`, `predicate` and `object` of `t` appear in `t`.
    - If the object of `t` is an `RDF triple` `t2`, then **any** `RDF term` appearing in `t2` also appears in `t`.
- By extension, an `RDF term` is said to `appear` in an `RDF graph` if it appears in an `asserted triple` of that graph. An `RDF triple` is said to `appear` in an `RDF graph` if it is either an `asserted triple` of that graph or a `triple term` appearing in that graph.
- An `RDF term` is said to be `ground` if any of the following three conditions holds:
    - It is an `IRI`.
    - It is a `literal`.
    - It is a `triple term` (s, p, o) such that `s`, `p`, and `o` are all `ground`.
- By extension, an `RDF triple` is said to be `ground` if its `subject`, `predicate`, and `object` are all `ground`. An `RDF graph` is said to be `ground` if all its `asserted triples` are `ground`.

### Literals
- Literals are used for values such as strings, numbers, and dates.
- A literal consists of two, three, or four components, as below:
    1. A `lexical form`, being an `RDF string`.
    2. A `datatype IRI`, being an `IRI` identifying a `datatype` that determines how the `lexical form` maps to a `literal value`.
    3. If and only if the `datatype IRI` is http://www.w3.org/1999/02/22-rdf-syntax-ns#langString or http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString, there is a non-empty `language tag` as defined by [BCP47]. The language tag MUST be well-formed according to section [2.2.9 of BCP47](https://www.rfc-editor.org/rfc/rfc5646#section-2.2.9), and MUST be treated accordingly, that is, in a **case-insensitive** manner. Two [BCP47]-complying strings that differ only by case represent the same `language tag`.
    4. If and only if the `datatype IRI` is http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString, there is a `base direction` that MUST be one of the following:
        - `ltr` indicating that the initial text direction is set to left-to-right
        - `rtl` indicating that the initial text direction is set to right-to-left
- A `literal` is a `language-tagged string` if the `language tag` is present and the `base direction` is not present. A `literal` is a `directional language-tagged string` if both the `language tag` and the `base direction` are present.

#### Representation of Literals
- Some concrete syntaxes support `simple literals` consisting of only a `lexical form` without any `datatype IRI`, `language tag`, or `base direction`. Simple literals are syntactic sugar for abstract syntax literals with the `datatype IRI` http://www.w3.org/2001/XMLSchema#string (which is commonly abbreviated as xsd:string).
- Similarly, most concrete syntaxes represent `language-tagged strings` and `directional language-tagged strings` without the `datatype IRI` because it is always either http://www.w3.org/1999/02/22-rdf-syntax-ns#langString (rdf:langString) or http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString (rdf:dirLangString), respectively.
- Any string complying with [BCP47] MAY be used to represent a language tag in concrete syntaxes or implementations. Such strings MAY be case normalized (for example, by canonicalizing as defined by BCP 47 section 4.5). Alternatively, an implementation MAY preserve the case from the original representation, provided that it processes it in a **case-insensitive** manner.
- **Note**: The treatment of language tags has changed between `RDF 1.1` and `RDF 1.2`. In `RDF 1.1`, "chat"@fr and "chat"@FR represent **two distinct terms**, but implementations may replace either with the other via some form of normalization. In `RDF 1.2`, they represent the **exact same literal**, i.e., the case difference in the concrete syntax does not propagate into the abstract syntax. Since many `RDF 1.1` implementations do normalize `language tags` internally, they will not be impacted by this change.

#### Literal Values
- The `literal value` associated with a `literal` is defined as follows.
    1. If the `literal` is a `language-tagged string`, then the `literal value` is a pair consisting of its `lexical form` and its `language tag`, in that order.
    2. If the `literal` is a `directional language-tagged string`, then the `literal value` is a tuple consisting of its `lexical form`, its `language tag`, and its `base direction`, in that order.
    3. If the literal's `datatype` is handled by an RDF implementation, then one of the following applies:
        - If the literal's `lexical form` is in the `lexical space` of the `datatype`, then the `literal value` is the result of applying the `lexical-to-value mapping` of the `datatype` to the `lexical form`.
        - Otherwise, the literal is `ill-typed` and no `literal value` can be associated with the `literal`. Such a case produces a `semantic inconsistency`, but it is not `syntactically ill-formed`. Implementations SHOULD accept `ill-typed literals` and produce `RDF graphs` from them. Implementations MAY produce warnings when encountering `ill-typed literals`.
    4. If the literal's `datatype IRI` is not handled by an RDF implementation, then the `literal value` is not defined by this specification. Implementations SHOULD accept literals with `unknown datatype IRIs` and produce `RDF graphs` from them.
- It follows from the above that two literals can have the same value without being the same `RDF term`. For example the following denote the same `value`, but are not the same literal `RDF term` because their `lexical forms` differ.:
```
"1"^^xsd:integer
"01"^^xsd:integer
```


## Equality Rules

### IRI Equality
Two `IRIs` are equal **if and only if** they consist of the same sequence of `Unicode code points`, as in Simple String Comparison in section 5.3.1 of [RFC3987]. (This is done in the abstract syntax, so the IRIs are resolved IRIs with no escaping or encoding.) Further normalization MUST NOT be performed before this comparison.

### Literal Term Equality
Literal term equality: two literals are term-equal (the same RDF term) **if and only if the following are all true**:
- The two `lexical forms` compare equal, where this comparison is performed using `case-sensitive matching` (see description of string comparison in [2.2 Strings in RDF](https://www.w3.org/TR/rdf12-concepts/#rdf-strings)).
- The two `datatype IRIs` compare equal (per `IRI equality`).
- The two `language tags` are either `both absent`, or `both present` and `compare equal`, where this comparison is performed using `ASCII case-insensitive matching` (in contrast to the case-sensitive comparison of the lexical forms)
- The two `base directions` are either both absent, both `ltr`, or both `rtl`.

### Blank Node Equality
- Blank node equality: Two blank nodes are equal if and only if they are the `same blank node`.
- **Note**: `Blank node identifiers` are local identifiers that are used in some concrete RDF syntaxes or RDF store implementations. They are **always locally scoped to the file or RDF store**, and are **not persistent or portable identifiers for blank nodes**. `Blank node identifiers` are not part of the RDF abstract data model, but are entirely dependent on the concrete syntax or implementation. The syntactic restrictions on blank node identifiers, if any, therefore also depend on the concrete RDF syntax or implementation. Implementations that handle blank node identifiers in concrete syntaxes need to be careful not to create the same blank node from multiple occurrences of the same blank node identifier except in situations where this is supported by the syntax.

### Triple Equality
- Triple equality: Two triples (s, p, o) and (s', p', o') are equal (the same `RDF triple`) if and only if all of the following three conditions hold:
    - s = s' (the `subjects` are equal)
    - p = p' (the `predicates` are equal)
    - o = o' (the `objects` are equal)
- **Note**: The definition of `triple` is _recursive_. That is, a `triple` can itself have an `object` component which is another `triple`. However, by this definition, cycles of `triples` **cannot** be created.

### String Equality
A string is identical to another string if it consists of the `same sequence of code points`. An implementation MAY determine string equality by comparing the code units of two strings that use the same Unicode character encoding (UTF-8 or UTF-16) without decoding the string into a Unicode code point sequence.
