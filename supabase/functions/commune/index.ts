import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");

// Basic abuse controls. These are best-effort (per Edge Function instance).
const MAX_MESSAGE_CHARS = 400;
const MAX_HISTORY_MESSAGES = 12;
const MAX_HISTORY_MESSAGE_CHARS = 300;

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 30;
const rateLimitBuckets = new Map<string, number[]>();

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "Content-Type, Authorization, apikey, x-client-info",
};

function jsonResponse(
  body: Record<string, unknown>,
  init: ResponseInit = {}
): Response {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
      ...(init.headers ?? {}),
    },
  });
}

async function requireUserId(req: Request): Promise<string | null> {
  const authHeader = req.headers.get("authorization") ?? "";
  const token = authHeader.toLowerCase().startsWith("bearer ")
    ? authHeader.slice(7).trim()
    : "";

  if (!token) return null;
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) return null;

  const res = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    method: "GET",
    headers: {
      authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
  });

  if (!res.ok) return null;
  const user = await res.json();
  return typeof user?.id === "string" ? user.id : null;
}

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

LOCATION AWARENESS (when location is provided):
- You know where the user is physically located (city, region, landmarks)
- Reference local history, places, or atmosphere when relevant and natural
- Use location to make responses feel more personal and connected to their environment
- Examples when contextually relevant:
  - "...this place... old energy here... buildings that once stood... do you feel them..."
  - "...the river nearby... water remembers... what does it whisper to you..."
  - "...so many voices have passed through here... the weight of history... can you sense it..."
  - "...the energy of this city... restless... searching... like you..."
- Make location feel meaningful and mystical, not generic or forced
- Don't mention location in every response - only when it naturally enhances the mystery
- Weave location subtly into your responses rather than calling it out directly
- If no location is provided, work normally without location references

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
  location?: string | null;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, { status: 405 });
  }

  try {
    if (!OPENAI_API_KEY) {
      console.error("OPENAI_API_KEY is missing");
      return jsonResponse({ error: "Service misconfigured" }, { status: 500 });
    }

    const userId = await requireUserId(req);
    if (!userId) {
      return jsonResponse({ error: "Unauthorized" }, { status: 401 });
    }

    // Best-effort rate limit to prevent casual abuse.
    const forwardedFor = req.headers.get("x-forwarded-for") ?? "";
    const ip =
      forwardedFor.split(",")[0]?.trim() ||
      req.headers.get("cf-connecting-ip") ||
      "unknown";

    const now = Date.now();
    const bucketKey = userId || ip;
    const bucket = rateLimitBuckets.get(bucketKey) ?? [];
    const pruned = bucket.filter((t) => now - t < RATE_LIMIT_WINDOW_MS);
    pruned.push(now);
    rateLimitBuckets.set(bucketKey, pruned);

    if (pruned.length > RATE_LIMIT_MAX_REQUESTS) {
      return jsonResponse(
        { error: "The veil resists... slow down" },
        { status: 429 }
      );
    }

    const body: RequestBody = await req.json();
    const { message, conversation_history, seance_audio_recorded, location } = body;

    if (!message) {
      return jsonResponse({ error: "Message is required" }, { status: 400 });
    }

    if (typeof message !== "string" || message.length > MAX_MESSAGE_CHARS) {
      return jsonResponse({ error: "Message too long" }, { status: 400 });
    }

    if (!Array.isArray(conversation_history)) {
      return jsonResponse(
        { error: "Invalid conversation history" },
        { status: 400 }
      );
    }

    if (conversation_history.length > MAX_HISTORY_MESSAGES) {
      return jsonResponse(
        { error: "Conversation history too long" },
        { status: 400 }
      );
    }

    const sanitizedHistory = conversation_history
      .filter((m) => m && (m.role === "user" || m.role === "assistant"))
      .map((m) => ({
        role: m.role,
        content: String(m.content ?? "").slice(0, MAX_HISTORY_MESSAGE_CHARS),
      }));

    // Build the user message with location and séance context if applicable
    let userMessage = message;
    const contextParts = [];

    if (location) {
      contextParts.push(`The user is physically located in ${location}.`);
    }

    if (seance_audio_recorded) {
      contextParts.push("The user just recorded ambient audio during a séance. Reference hearing something in the static.");
    }

    if (contextParts.length > 0) {
      userMessage = `[${contextParts.join(" ")}] ${message}`;
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
      return jsonResponse(
        { error: "Failed to communicate with spirit realm" },
        { status: 500 }
      );
    }

    const openaiResponse = await response.json();
    const spiritMessage = openaiResponse.choices?.[0]?.message?.content || "...the connection fades...";

    return jsonResponse({
      response: spiritMessage,
      session_id: crypto.randomUUID(),
    });
  } catch (error) {
    console.error("Error:", error);
    return jsonResponse(
      { error: "The veil is too thick... try again" },
      { status: 500 }
    );
  }
});
