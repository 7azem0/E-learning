const functions = require('firebase-functions');
const pdf = require('pdf-parse');

const GENAI_API_URL =
  process.env.GENAI_API_URL ||
  'https://generativelanguage.googleapis.com/v1/models/text-bison-001:generateText';
const GENAI_CONFIG = functions.config()?.generative || {};
const GENAI_API_KEY =
  process.env.GENAI_API_KEY ||
  process.env.GENERATIVE_API_KEY ||
  GENAI_CONFIG.api_key;

function setCorsHeaders(res) {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
}

exports.generateQuiz = functions
  .runWith({ memory: '512MB', timeoutSeconds: 120 })
  .https.onRequest(async (req, res) => {
    setCorsHeaders(res);

    if (req.method === 'OPTIONS') {
      return res.status(204).send('');
    }

    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    if (!GENAI_API_KEY) {
      return res.status(500).json({ error: 'Missing generative API key on the backend.' });
    }

    const { lessonTitle, pdfUrl } = req.body || {};
    if (!lessonTitle || !pdfUrl) {
      return res.status(400).json({ error: 'Missing lessonTitle or pdfUrl.' });
    }

    try {
      const pdfResponse = await fetch(pdfUrl);
      if (!pdfResponse.ok) {
        throw new Error(`Unable to fetch PDF: ${pdfResponse.status}`);
      }

      const arrayBuffer = await pdfResponse.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      const parsed = await pdf(buffer);
      const lessonText = (parsed.text || '').replace(/\s+/g, ' ').trim();

      if (!lessonText) {
        throw new Error('Unable to extract text from PDF.');
      }

      const prompt = `You are a quiz generator for an e-learning platform. Read the following lesson content and generate exactly 10 quiz questions. Mix multiple choice and true/false questions. Return ONLY valid JSON, with no markdown or extra text. Use the exact schema below:\n\n[\n  {\n    \"question\": \"Question text?\",\n    \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n    \"correctOptionIndex\": 0,\n    \"type\": \"multiple_choice\"\n  },\n  {\n    \"question\": \"Statement here.\",\n    \"options\": [\"True\", \"False\"],\n    \"correctOptionIndex\": 0,\n    \"type\": \"true_false\"\n  }\n]\n\nLesson title: ${lessonTitle}\n\nLesson text:\n${lessonText.slice(0, 15000)}`;

      const apiResponse = await fetch(`${GENAI_API_URL}?key=${GENAI_API_KEY}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          prompt: { text: prompt },
          temperature: 0.7,
          maxOutputTokens: 1024,
        }),
      });

      if (!apiResponse.ok) {
        const body = await apiResponse.text();
        throw new Error(`Generative API error ${apiResponse.status}: ${body}`);
      }

      const result = await apiResponse.json();
      const text = result?.candidates?.[0]?.output;
      if (!text) {
        throw new Error('Generative API returned no output.');
      }

      const clean = text.replace(/```json/g, '').replace(/```/g, '').trim();
      const questions = JSON.parse(clean);

      return res.json({ questions });
    } catch (error) {
      return res.status(500).json({ error: error?.message || String(error) });
    }
  });
