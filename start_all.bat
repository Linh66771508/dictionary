@echo off
setlocal

set ROOT=D:\study\dictionary
set BACKEND_EXE=%ROOT%\backend\dist\dictionary_backend.exe
set BACKEND_ENV=%ROOT%\backend\.env
set APP_EXE=%ROOT%\dictionary_app\build\windows\x64\runner\Release\dictionary_app.exe
set ADMIN_EXE=%ROOT%\dictionary_admin_app\build\windows\x64\runner\Release\dictionary_admin_app.exe

if exist "%BACKEND_EXE%" (
  echo Starting backend exe...
  start "Dictionary Backend" "%BACKEND_EXE%"
) else (
  echo Backend exe not found. Starting uvicorn with Python...
  if not exist "%BACKEND_ENV%" (
    echo Missing .env at %ROOT%\backend\.env
    echo Copy .env.example to .env and edit SQLSERVER_CONN_STR first.
    goto :after_backend
  )
  pushd "%ROOT%\backend"
  start "Dictionary Backend" cmd /c "python -m uvicorn app.main:app --host 127.0.0.1 --port 8000"
  popd
)

:after_backend

if exist "%APP_EXE%" (
  echo Starting dictionary app...
  start "Dictionary App" "%APP_EXE%"
) else (
  echo App exe not found. Build it with:
  echo   flutter build windows --release
)

if exist "%ADMIN_EXE%" (
  echo Starting admin app...
  start "Dictionary Admin" "%ADMIN_EXE%"
) else (
  echo Admin exe not found. Build it with:
  echo   flutter build windows --release
)

echo Done.
endlocal
