import os
import subprocess
import time
import urllib.request
import urllib.error

ROOT = r"D:\study\dictionary"
BACKEND_EXE = os.path.join(ROOT, "backend", "dist", "dictionary_backend.exe")
BACKEND_ENV = os.path.join(ROOT, "backend", ".env")
APP_EXE = os.path.join(ROOT, "dictionary_app", "build", "windows", "x64", "runner", "Release", "dictionary_app.exe")
ADMIN_EXE = os.path.join(ROOT, "dictionary_admin_app", "build", "windows", "x64", "runner", "Release", "dictionary_admin_app.exe")

BACKEND_URL = "http://127.0.0.1:8000/health"


def wait_for_backend(timeout_seconds=20):
    start = time.time()
    while time.time() - start < timeout_seconds:
        try:
            with urllib.request.urlopen(BACKEND_URL, timeout=1) as resp:
                if resp.status == 200:
                    return True
        except Exception:
            time.sleep(0.5)
    return False


def start_backend():
    if os.path.exists(BACKEND_EXE):
        subprocess.Popen([BACKEND_EXE], creationflags=subprocess.CREATE_NEW_CONSOLE)
        return True
    if not os.path.exists(BACKEND_ENV):
        print("Missing .env. Please copy backend/.env.example to backend/.env and set SQLSERVER_CONN_STR.")
        return False
    backend_dir = os.path.join(ROOT, "backend")
    subprocess.Popen(
        ["python", "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", "8000"],
        cwd=backend_dir,
        creationflags=subprocess.CREATE_NEW_CONSOLE,
    )
    return True


def start_app(path, title):
    if os.path.exists(path):
        subprocess.Popen([path], creationflags=subprocess.CREATE_NEW_CONSOLE)
    else:
        print(f"Missing {title} exe at: {path}")


def main():
    ok = start_backend()
    if ok:
        wait_for_backend()
    start_app(APP_EXE, "Dictionary App")
    start_app(ADMIN_EXE, "Dictionary Admin")


if __name__ == "__main__":
    main()
