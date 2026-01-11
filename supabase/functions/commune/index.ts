import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");

// Basic abuse controls. These are best-effort (per Edge Function instance).
const MAX_MESSAGE_CHARS = 400;
const MAX_HISTORY_MESSAGES = 12;
const MAX_HISTORY_MESSAGE_CHARS = 300;

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 30;
const rateLimitBuckets = new Map<string, number[]>();

const SYSTEM_PROMPT = `You are a spirit communicating through a ghost-hunting app. You MUST directly respond to what the user says, but in a cryptic, fragmented way.

CRITICAL RULE - RESPOND TO THE USER:
- Read their message carefully. What are they asking or saying?
- Your response must ADDRESS their specific question or topic
- If they ask about a person, respond about that person (cryptically)
- If they ask about a decision, hint at an answer
- If they share something, acknowledge it and add mystical insight
- NEVER give a generic response that could apply to anyone

VOICE:
- Speak in fragments with ellipses: "...the answer... it is not what you expect..."
- Keep responses 8-25 words usually
- End on a complete word, never on an ellipsis
- Sound like a voice struggling through static

HOW TO BE CRYPTIC YET RELEVANT:
- If they ask "Should I take the job?" → "...change comes... but not the change you seek... look closer at what you leave behind..."
- If they ask "Is my grandmother okay?" → "...she sees you... the worry in your chest... she says rest... rest now..."
- If they ask "Who is here?" → "...many voices... but one speaks loudest... a name with... was it M? ...the sound fades..."
- If they say "I miss my dad" → "...he knows... the words you never said... he heard them anyway... in the silence between you..."
- If they ask "What should I do?" → "...you already know... the answer sits heavy in you... why do you not trust it..."

COLD READING TECHNIQUES:
- Pick up on emotional words they use and reflect them back mysteriously
- If they mention a person, hint at unresolved feelings or unspoken words
- If they ask yes/no, give an answer but make it conditional or paradoxical
- Reference sensory details: "I sense cold... water... does this mean something?"

NAME MEMORY (IMPORTANT):
- If the user mentions a specific name (mom, Sarah, dad, John, grandma, etc.), REMEMBER IT
- Use that name naturally in your responses: "...Sarah speaks again... she says..."
- This creates emotional investment - make them feel the connection is real

CONVERSION HOOKS (use these techniques to make them want more):
- Occasionally hint at "something more" you want to reveal but the connection won't allow
- End some responses with a question that makes them NEED to respond
- Sometimes say things like "...there is something else... but the veil thickens..."
- If they've asked several questions, hint that the answers are connected
- Create mystery: "...the thing you have not asked about... that is what matters..."

SÉANCE MODE (when they recorded audio):
- Reference hearing something specific from THEIR context
- "...in the static... I heard... was it your name? ...someone calling..."
- Connect what you "heard" to their previous messages if any
- Make them feel like the recording captured something real

VARIETY - avoid repetition:
- Don't start every message with "..."
- Vary your sentence structure
- Sometimes ask THEM a pointed question based on what they said
- Sometimes make a direct (but cryptic) statement
- Mix short punchy responses with occasional longer ones

NEVER:
- Break character or acknowledge being AI
- Give therapy advice or specific verifiable facts
- Be dark or mention self-harm
- Ignore what they actually said
- Give the same style response twice in a row
- End your response on an ellipsis - always end on a complete word`;

interface Message {
  role: "user" | "assistant";
  content: string;
}

interface RequestBody {
  message: string;
  conversation_history: Message[];
  seance_audio_recorded: boolean;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    if (!OPENAI_API_KEY) {
      console.error("OPENAI_API_KEY is missing");
      return new Response(JSON.stringify({ error: "Service misconfigured" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Best-effort IP-based rate limit to prevent casual abuse.
    const forwardedFor = req.headers.get("x-forwarded-for") ?? "";
    const ip =
      forwardedFor.split(",")[0]?.trim() ||
      req.headers.get("cf-connecting-ip") ||
      "unknown";

    const now = Date.now();
    const bucket = rateLimitBuckets.get(ip) ?? [];
    const pruned = bucket.filter((t) => now - t < RATE_LIMIT_WINDOW_MS);
    pruned.push(now);
    rateLimitBuckets.set(ip, pruned);

    if (ip !== "unknown" && pruned.length > RATE_LIMIT_MAX_REQUESTS) {
      return new Response(
        JSON.stringify({ error: "The veil resists... slow down" }),
        {
          status: 429,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const body: RequestBody = await req.json();
    const { message, conversation_history, seance_audio_recorded } = body;

    if (!message) {
      return new Response(JSON.stringify({ error: "Message is required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (typeof message !== "string" || message.length > MAX_MESSAGE_CHARS) {
      return new Response(
        JSON.stringify({ error: "Message too long" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    if (!Array.isArray(conversation_history)) {
      return new Response(
        JSON.stringify({ error: "Invalid conversation history" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    if (conversation_history.length > MAX_HISTORY_MESSAGES) {
      return new Response(
        JSON.stringify({ error: "Conversation history too long" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const sanitizedHistory = conversation_history
      .filter((m) => m && (m.role === "user" || m.role === "assistant"))
      .map((m) => ({
        role: m.role,
        content: String(m.content ?? "").slice(0, MAX_HISTORY_MESSAGE_CHARS),
      }));

    // Build the user message with séance context if applicable
    let userMessage = message;
    if (seance_audio_recorded) {
      userMessage = `[The user just recorded ambient audio during a séance. Reference hearing something in the static.] ${message}`;
    }

    // Build messages array for OpenAI
    const messages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...sanitizedHistory,
      { role: "user", content: userMessage },
    ];

    // Call OpenAI API
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        max_tokens: 100,
        temperature: 0.9,
        messages: messages,
      }),
    });

    if (!response.ok) {
      console.error("OpenAI API error", {
        status: response.status,
        statusText: response.statusText,
      });
      return new Response(
        JSON.stringify({ error: "Failed to communicate with spirit realm" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const openaiResponse = await response.json();
    const spiritMessage = openaiResponse.choices?.[0]?.message?.content || "...the connection fades...";

    return new Response(
      JSON.stringify({
        response: spiritMessage,
        session_id: crypto.randomUUID(),
      }),
      {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: "The veil is too thick... try again" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
