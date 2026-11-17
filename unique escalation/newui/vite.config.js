import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const proxyTarget = env.VITE_API_PROXY_TARGET;
  const proxyPrefix = env.VITE_API_PROXY_PREFIX || "";

  return {
    base: "./",
    plugins: [react()],
    build: {
      rollupOptions: {
        input: resolve(process.cwd(), "vite-entry.html"),
        output: {
          entryFileNames: "assets/app.js",
          chunkFileNames: "assets/[name].js",
          assetFileNames: "assets/[name].[ext]"
        }
      }
    },
    server: proxyTarget
      ? {
          proxy: {
            "/api": {
              target: proxyTarget,
              changeOrigin: true,
              rewrite: (path) => `${proxyPrefix}${path}`
            }
          }
        }
      : undefined
  };
});
