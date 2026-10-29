# 21 · Semantic / vector search

Augments keyword search (12) with meaning-based retrieval.

## Approach
- Generate embeddings for products (name + description + attributes) via an embedding
  provider (`IEmbeddingProvider`); store vectors in **pgvector** (locked default, since
  PostgreSQL is already the DB). OpenSearch's vector feature is an allowed alternative behind
  the same abstraction, but build on pgvector.
- Query: embed the user's query → nearest-neighbor search → blend with keyword results
  (hybrid ranking) for best relevance.
- Re-embed on `ProductChanged` (02).

## Rules
- Tenant-scoped vectors; filter by tenant on every query.
- Fall back to keyword search (12) if the embedding provider is down.
- Don't send secrets/PII to the provider; only public product text.

## API surface
- Hybrid search endpoint (extends module 12); reindex embeddings job.
