# 21 · Chatbot / shopping assistant

A conversational assistant for support and guided shopping, across web and bot channels (15).

## Approach
- An LLM provider behind `IAssistantProvider`; ground answers with **retrieval** over the
  tenant's own data (products, policies, FAQs, order status) — RAG, not free hallucination.
- Tool/function calling to safe, scoped actions: search products, check order status
  (owner-verified), start a return, answer policy questions.
- Hand off to a human (support tickets, 09) when confidence is low or asked.

## Rules
- The assistant acts only through existing authorized APIs with the user's own permissions —
  never bypass authz; verify identity before exposing order/account data.
- Guard against prompt injection from product/user content; treat retrieved text as data.
- Don't send PII/secrets to the model beyond what's needed and consented.
- Tenant-scoped knowledge; rate-limited; logged (no secrets).

## API surface
- Chat endpoint (web + bot); retrieval index build; escalation to human.
