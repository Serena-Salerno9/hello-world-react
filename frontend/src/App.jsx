import { useState } from "react";

export default function App() {
  const [message, setMessage] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  async function fetchMessage() {
    setLoading(true);
    setError(null);
    try {
      const base = import.meta.env.VITE_API_URL || "http://localhost:8000";
      const url = `${base.replace(/\/$/, "")}/hello`;
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setMessage(data.message);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ fontFamily: "sans-serif", padding: "2rem" }}>
      <h1>Hello World React</h1>
      <button
        onClick={fetchMessage}
        disabled={loading}
        style={{
          padding: "0.5rem 1rem",
          color: "white",
          backgroundColor: "#1e00ffff",
          border: "none",
          borderRadius: "4px",
          cursor: "pointer",
        }}
      >
        {loading ? "Loading..." : "Get Message From Backend"}
      </button>
      {message && <p style={{ marginTop: "1rem" }}>Backend: {message}</p>}
      {error && (
        <p style={{ marginTop: "1rem", color: "red" }}>Error: {error}</p>
      )}
    </div>
  );
}
