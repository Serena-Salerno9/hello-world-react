import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  // La base DEVE rimanere sempre '/' perché il frontend sarà servito dalla root del suo dominio (sia localhost:8080 che Cloud Run)
  base: '/',
  server: {
    port: 8080,
  },
  build: {
    outDir: 'dist'
  },
});